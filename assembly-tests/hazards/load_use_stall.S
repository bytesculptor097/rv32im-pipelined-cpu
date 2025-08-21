.section .data
val: .word 99

.section .text
.globl _start

_start:
    la x1, val         # x1 = address of val
    lw x2, 0(x1)       # x2 = 99
    add x3, x2, x2     # x3 = 198 (dependent on x2)
    add x4, x3, x2     # x4 = 297 (further dependency)

end:
    j end
