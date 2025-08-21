.section .text
.globl _start

_start:
    li x1, 5
    li x2, 3

    add x3, x1, x2     # x3 = 8
    sub x4, x1, x2     # x4 = 2
    and x5, x1, x2     # x5 = 1
    or  x6, x1, x2     # x6 = 7
    xor x7, x1, x2     # x7 = 6
    sll x8, x1, x2     # x8 = 5 << 3 = 40
    srl x9, x1, x2     # x9 = 5 >> 3 = 0
    sra x10, x1, x2    # x10 = 5 >> 3 (arith) = 0

end:
    j end
