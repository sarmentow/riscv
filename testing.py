import sys, ctypes, operator
op = '+'
ops = {
        '+': operator.add,
        '-': operator.sub,
        '<': operator.lt,
        '<<': operator.lshift,
        '>>': operator.rshift,
        '*': operator.mul
}
with open(sys.argv[1], 'r') as testfile:
    next(testfile)
    for line in testfile:
            line = line.split(' ')
            a = ctypes.c_int32((int(line[1], base=16))).value
            b = ctypes.c_int32((int(line[2], base=16))).value
            c = ctypes.c_int32((int(line[3], base=16))).value
            if a + b == c:
                print('success', a, op, b, "=", c)
            else:
                print('fail', a, op, b, "!=", c)

        
