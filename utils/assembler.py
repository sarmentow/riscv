# Translates RISC-V assembly into binary to make it easier to setup tests in 'blocks/insmem.v'
# Basically an assembler that instead of outputting a binary file, outputs the file that setups
# instruction memory.

# Takes in an assembly file path as argument and outputs a corresponding insmem.v file
# For now won't support comments

import sys

ops = {'ori', 'jalr', 'bne', 'lw', 'and', 'addi', 'add', 'sb', 'xor', 'sll', 'lbu', 'sltiu', 'sh', 'srli', 'sltu', 'blt', 'beq', 'lh', 'sub', 'slt', 'lhu', 'jal', 'bltu', 'sra', 'sw', 'slti', 'lb', 'srai', 'srl', 'bge', 'andi', 'slli', 'bgeu', 'xori', 'or', 'auipc', 'lui'}
class Parser:
    def __init__(self, line):
        self.line = line
        self.op = line.split(' ')[0]
        assert self.op in ops
        self.args = self.get_args()

    def get_args(self):
        args = []
        last_separator_idx = -1 
        prev_stop_separator = None
        for idx, c in enumerate(self.line):
            if c == ' ' or c == ',' or c == '\n' or c == '(' or c == ')':
                if not prev_stop_separator: args.append(self.line[last_separator_idx+1:idx])
                last_separator_idx = idx
                prev_stop_separator = True
            else:
                prev_stop_separator = False
        return args

# easier to write than a dict for now 
# TODO this looks terrible
def opcode(op):
    if op == 'jal': return '1101111'
    elif op == 'jalr': return '1100111'
    elif op in 'beq bne blt bge bltu bgeu'.split(' '): return '1100011'
    elif op in 'lb lh lw lbu lhu'.split(' '): return '0000011' 
    elif op in 'sb sh sw'.split(' '): return '0100011'
    elif op in 'addi slti sltiu xori ori andi slli srli srai'.split(' '): return '0010011'
    elif op in 'add sub sll slt sltu xor srl sra or and'.split(' '): return '0110011'
    elif op == 'lui': return '0110111'
    elif op == 'auipc': return '0010111'
    else: return None

def optype(op):
    if op in ' add sub sll slt sltu xor srl sra or and'.split(' '): return 'r'
    elif op in 'jalr lb lh lw lbu lhu addi slti sltiu xori ori andi slli srli srai'.split(' '): return 'i'
    elif op in 'sb sh sw'.split(' '): return 's'
    elif op == 'jal': return 'j'
    elif op in 'beq bne blt bge bltu bgeu'.split(' '): return 'b'
    elif op in 'lui auipc'.split(' '): return 'u'
    else: return None


r_ops = 'add sub sll slt sltu xor srl sra or and'.split(' ')
r_funct3_list = '000 000 001 010 011 100 101 101 110 111'.split(' ')
r_funct7_list = '0000000 0100000 0000000 0000000 0000000 0000000 0000000 0100000 0000000 0000000'.split(' ')
r_funct3 = dict(zip(r_ops, r_funct3_list))
r_funct7 = dict(zip(r_ops, r_funct7_list))

i_ops = 'lb lh lw lbu lhu addi slti sltiu xori ori andi'.split(' ')
i_funct3_list = '000 001 010 100 101 000 010 011 100 110 111'.split(' ')
i_funct3 = dict(zip(i_ops, i_funct3_list))

s_ops = 'sb sh sw'.split(' ')
s_funct3_list = '000 001 010'.split(' ')
s_funct3 = dict(zip(s_ops, s_funct3_list))

b_ops = 'beq bne blt bge bltu'.split(' ')
b_funct3_list = '000 001 100 101 110 111'.split(' ')
b_funct3 = dict(zip(b_ops, b_funct3_list))

regcodes = [f'x{i}' for i in range(32)]
register = dict(zip(regcodes, [ f'{i:05b}' for i in range(32)]))

class Translator:


    def __init__(self):
        self.p = None
        self.args = None

    def set_parser(self, parser):
        self.p = parser
        self.args = parser.get_args()

    def translate(self):
        assert self.p != None
        opc = opcode(self.p.op)
        assert opc
        opt = optype(self.p.op)
        assert opt
        if opt == 'r':
           rd = register[self.args[1]]
           rs1 = register[self.args[2]]
           rs2 = register[self.args[3]]
           funct_3 = r_funct3[self.p.op]
           funct_7 = r_funct7[self.p.op]
           return funct_7 + rs2 + rs1 + funct_3 + rd + opc
        elif opt == 'i':
            # arg position differs between load and arithmetic
            # lw x0, 0(x4)
            # addi x1, x0, 4
            rd = register[self.args[1]]
            rs1 = None
            imm = None
            funct_3 = i_funct3[self.p.op]
            if self.p.op in 'lb lh lw lbu lhu jalr'.split(' '):
                rs1 = register[self.args[3]]
                imm = f'{int(self.args[2]):012b}'
            else:
                rs1 = register[self.args[2]]
                imm = f'{int(self.args[3]):012b}'
            assert rs1 and imm
            return imm + rs1 + funct_3 + rd + opc
        elif opt == 's':
            imm = f'{int(self.args[2]):012b}'
            funct_3 = s_funct3[self.p.op]
            rs1 = register[self.args[3]]
            rs2 = register[self.args[1]]
            imm = imm[::-1]
            return imm[5:][::-1] + rs2 + rs1 + funct_3 + imm[0:5][::-1] + opc
        elif opt == 'j':
            # TODO won't support labels for now, only immediate offsets
            # jal rd, imm     
            rd = register[self.args[1]]
            if int(self.args[2]) < 0:
                imm = format(int(self.args[2]) % (1<<21), 'b')
            else:
                imm = f'{int(self.args[2]):021b}'
            imm = imm[::-1]
            return imm[20] + imm[1:11][::-1] + imm[11] + imm[12:20][::-1] + rd + opc
        elif opt == 'b':
            # beq rs1, rs2, off
            rs1 = register[self.args[1]]
            rs2 = register[self.args[2]]
            assert int(self.args[3]) % 2 == 0
            imm = f'{int(self.args[3]):013b}' # 13 bit number and I'll discard the last bit
            funct3 = b_funct3[self.p.op]
            # Must reverse because imm[0] gives me the most significant bit and I want the opposite behaviour
            imm = imm[::-1]
            # TODO This doesn't look right, there's something simpler that I could do here to get the indexing and ordering
            # correct but I'll do this later; First I'll test the core.
            return imm[12] + imm[5:11][::-1] + rs2 + rs1 + funct3 + imm[1:5][::-1] + imm[11][::-1] + opc
        elif opt == 'u':
            # lui x1, 290
            rd = register[self.args[1]]
            imm = f'{int(self.args[2]):020b}'
            return imm + rd + opc



class Writer:
    def __init__(self):
        # current_byte
        self.cb = 0

    def write_test(self, ins, line):
        if line[-1] == '\n': line = line[:-1]
        assert len(ins) == 32 
        beg, end = 24, 31
        print(f'// {line}')
        for _ in range(4):
            print(f'ins[{self.cb}] <= 8\'b{ins[beg:end+1]};')
            beg -= 8
            end -= 8
            self.cb += 1
        print()

    def write_hex(self, ins, line):
        if line[-1] == '\n': line = line[:-1]
        print(f'// {line}')
        print(f'{hex(int(ins, 2))}')

with open(sys.argv[1], 'r') as f:
#with open('./eg.txt', 'r') as f:
    t = Translator()
    w = Writer()
    for line in f:
        p = Parser(line)
        t.set_parser(p)
        if sys.argv[2] == 'translate':
            print(line[:-1] if line[-1] == '\n' else line)
            print(t.translate())
        elif sys.argv[2] == 'test':
            w.write_test(t.translate(), line)
        elif sys.argv[2] == 'hex':
            w.write_hex(t.translate(), line)

