addi x1, x0, 5
addi x5, x0, 2
addi x2, x0, 0
addi x3, x0, 1
comp:
bge x5, x1, end
add x4, x3, x2
addi x2, x3, 0
addi x3, x4, 0
addi x5, x5, 1
addi x6, x6, 4
sw x4, 0(x6)
jal x0, comp
end:
addi x0, x0, 0

