    .section .text
    .globl _start

_start:
    li x1, 0          # fib(0)
    li x2, 1          # fib(1)
    li x3, 8          # loop count (remaining terms)

loop:
    add x4, x1, x2    # x4 = fib(n)
    add x1, x0, x2    # x1 = previous x2
    add x2, x0, x4    # x2 = new fib(n)
    addi x3, x3, -1   # decrement counter
    beq x3, x0, end   # if counter == 0, exit
    jal x0, loop      # jump to loop

end:
    j end             # infinite loop
