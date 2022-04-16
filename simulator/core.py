import operator

def srl(a, b):
    a_unsigned = a & 0xffffffff
    a_unsigned_shifted = a_unsigned >> b
    return a_unsigned_shifted

def ltu(a, b):
    a_unsigned = a & 0xffffffff
    b_unsigned = b & 0xffffffff
    return a < b

class Simulation:
    op = {'add': operator.add,
          'sub': operator.sub,
          'xor': operator.xor,
          'or': operator.or_,
          'and': operator.and_,
          'sra': operator.rshift,
          'sla': operator.lshift,
          'srl': srl,
          'slt': operator.lt,
          'sltu': ltu,
            }

    def __init__(self, program):
        self.bus = Bus()
        self.cpu = CPU(self.bus) 
        self.program = program

    def step(self): # This corresponds to a clock cycle
        ins = next(program)
        # TODO import a parser, no need to rewrite one
        

class Bus: 
    def __init__(self):
        self.addr = 0
        self.data = 0
        self.write = 0
        self.busy = 0

# This is the part of the simulation in which I'll need the least amount 
# of accuracy in describing given that I've already implemented a RISC-V
# core and the purpose of the simulation isn't to test CPU design but to
# help think about system communication
class CPU: 
    def __init__(self, bus, stall=False):
        self.register = [0 for _ in range(32)]
        self.program_counter = 0
        self.bus = bus
        self.stall = stall
        self.loading = False
        self.storing = False

    def step(self, ins):
        if not self.stall:
            if self.loading:
                pass
            elif self.storing:
                pass
            else:
                pass
            pass
    
    def jump(self, offset):  
        self.program_counter = self.program_counter + offset 

    def reg_reg_arithmetic(self, op, reg_rd, reg_rs1, reg_rs2):
        self.register[reg_rd] = op(self.register[reg_rs1], self.register[reg_rs2])

    def reg_imm_arithmetic(self, op, reg_rd, reg_rs1, imm):
        self.register[reg_rd] = op(self.register[reg_rs1], imm)

    def load_bus_send(self, addr, reg_rd): # TODO model memory latency
        if not self.bus.busy:
            self.bus.busy = 1
            self.bus.addr = addr

    def load_bus_receive(self, addr, reg_rd):
        assert self.bus.busy, 'Tried loading (bus_receive) data without owning the bus'
        self.bus.busy = 0 
        self.bus.addr = 0
        self.register[reg_rd] = self.bus.data

    def store_bus_send(self, offset, reg_rs1, reg_rs2): # TODO same as above
        if not self.bus.busy:
            self.bus.busy = 1
            self.bus.addr = offset + self.register[reg_rs1]
            self.bus.data = self.register[reg_rs2]

    def store_bus_receive(self, offset, reg_rs1, reg_rs2): # TODO same as above
        assert self.bus.busy, 'Tried concluding a store (bus_receive) instruction without owning the bus'
        self.bus.busy = 0
        self.bus.addr = 0
        self.bus.data = 0

        

    def branch(self, offset, reg_rs1, reg_rs2, op):
        if op(self.register[reg_rs1], self.register[reg_rs2]):
            self.program_counter += offset

    def lui(self, imm, reg_rd):
        self.register[reg_rd] = imm << (32 - 20) 

    def auipc(self, imm, reg_rd):
        self.register[reg_rd] = (imm << (32 - 20))  + self.program_counter
    
class Memory:
    pass

class GPU:
    pass

sim = Simulation(input())
