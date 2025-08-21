.section .text
.globl _start

_start:
    li x1, 5

    addi x2, x1, 3     # x2 = 8
    andi x3, x1, 2     # x3 = 0
    ori  x4, x1, 2     # x4 = 7
    xori x5, x1, 1     # x5 = 4
    slti x6, x1, 10    # x6 = 1 (5 < 10)

end:
    j end
