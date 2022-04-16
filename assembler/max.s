addi x1, x0, 2
sw x1, 0(x0)
addi x1, x0, 3
sw x1, 4(x0)
addi x1, x0, 4
sw x1, 8(x0)
addi x1, x0, 8
sw x1, 12(x0)
addi x1, x0, 21
sw x1, 16(x0)
addi x1, x0, 2 
sw x1, 20(x0)
addi x1, x0, 30
sw x1, 24(x0)
addi x1, x0, 100
sw x1, 28(x0)
addi x1, x0, 31
sw x1, 32(x0)
addi x1, x0, 36
addi x2, x0, 0
lw x3, 0(x2)
bge x2, x1, 28 
lw x4, 0(x2)
addi x0, x0, 0
bge x3, x4, 8
add x3, x4, x0
addi x2, x2, 4
jal x0, -24
addi x0, x0, 0
