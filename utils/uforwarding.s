lui x1, 1
lui x2, 2
bge x2, x1, branch
addi x1, x0, 4
addi x2, x0, 8
branch:
addi x1, x1, 256
