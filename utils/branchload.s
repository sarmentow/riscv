addi x1, x0, 8
sw x1, 0(x0)
addi x1, x0, 92
sw x1, 4(x0)
lw x2, 0(x0)
lw x3, 4(x0)
bge x3, x2, 16
addi x1, x0, 1
addi x2, x0, 1
addi x3, x0, 1
addi x0, x0, 0
