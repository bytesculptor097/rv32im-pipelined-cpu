.section .text
.globl _start

_start:
    li x1, 0          # fib(0)
    li x2, 1          # fib(1)
    li x3, 10         # loop count
    li x4, 0          # temp
    li x5, 0          # counter

loop:
    add x4, x1, x2    # x4 = x1 + x2
    mv x1, x2         # shift
    mv x2, x4         # shift
    addi x5, x5, 1    # counter++
    blt x5, x3, loop  # loop until x5 < x3

end:
    j end
