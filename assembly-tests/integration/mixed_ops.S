.section .text
.globl _start

_start:
    li x1, 10
    li x2, 20
    add x3, x1, x2        # x3 = 30
    mul x4, x3, x1        # x4 = 300
    sw x4, 0(x2)          # store to mem
    lw x5, 0(x2)          # load back
    beq x4, x5, match     # branch if equal
    li x6, 0              # should be flushed

match:
    li x6, 1              # executed if branch taken

end:
    j end
