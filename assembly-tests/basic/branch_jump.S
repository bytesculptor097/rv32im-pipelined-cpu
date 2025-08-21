.section .text
.globl _start

_start:
    li x1, 5
    li x2, 5
    li x3, 0

    beq x1, x2, label1 # branch taken
    addi x3, x3, 1     # skipped

label1:
    bne x1, x2, label2 # not taken
    addi x3, x3, 2     # executed

label2:
    jal x4, jump_target
    addi x3, x3, 4     # skipped

jump_target:
    addi x3, x3, 8     # executed

end:
    j end
