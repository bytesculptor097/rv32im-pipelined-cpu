.section .text
.globl _start

_start:
    li x1, 1
    li x2, 2
    li x3, 0

    beq x1, x2, wrong_path  # not taken
    addi x3, x3, 1          # should execute

wrong_path:
    addi x3, x3, 2          # should be skipped if branch not taken

end:
    j end
