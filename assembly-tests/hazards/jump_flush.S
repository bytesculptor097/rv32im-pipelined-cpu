.section .text
.globl _start

_start:
    li x1, 5
    li x2, 0

    jal x3, jump_target     # jump to jump_target
    addi x2, x2, 1          # should be flushed

jump_target:
    addi x2, x2, 2          # executed after jump

end:
    j end
