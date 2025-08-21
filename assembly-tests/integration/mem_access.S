.section .data
arr: .word 1, 2, 3, 4, 5

.section .text
.globl _start

_start:
    la x1, arr        # base address
    li x2, 0          # index
    li x3, 5          # limit
    li x4, 0          # sum

loop:
    lw x5, 0(x1)      # load arr[i]
    add x4, x4, x5    # sum += arr[i]
    addi x1, x1, 4    # next element
    addi x2, x2, 1    # index++
    blt x2, x3, loop  # loop until index < 5

end:
    j end
