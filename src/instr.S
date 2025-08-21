    .text
    .globl _start

_start:
    li x1, 5           # x1 = 5
    li x2, 10          # x2 = 10
    add x3, x1, x2     # x3 = x1 + x2 = 15
    sub x4, x3, x1     # x4 = x3 - x1 = 10 (RAW hazard on x3)
    mul x5, x4, x1     # x5 = x4 * x1 = 50 (RAW hazard on x4)

    li x6, 0           # x6 = loop counter
    li x7, 3           # x7 = loop limit
loop:
    addi x6, x6, 1     # x6++
    beq x6, x7, exit   # branch taken on 3rd iteration
    jal x0, loop       # jump back to loop (flush test)

exit:
    li x8, 100         # x8 = 100
    sw x8, 0(x5)       # store x8 at address in x5
    lw x9, 0(x5)       # load back into x9 (memory test)

    add x10, x9, x1    # x10 = x9 + x1 = 105
