.section .data
mem:
    .word 42, 84

.section .text
.globl _start

_start:
    la x1, mem         # x1 = address of mem
    lw x2, 0(x1)       # x2 = 42
    lw x3, 4(x1)       # x3 = 84

    li x4, 100
    sw x4, 0(x1)       # mem[0] = 100

end:
    j end
