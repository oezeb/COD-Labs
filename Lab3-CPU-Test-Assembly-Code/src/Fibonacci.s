.data
out: .word 0
in1: .word 1
in2: .word 2

.text
    la a0, out
    lw a1, in1
    sw a1, 0(a0)  # print out
    lw a2, in2
    sw a2, 0(a0)  # print out

fibonacci: # a0 --> output a1 --> numb1, a2 --> numb2
    add t0, a1, a2
    sw t0, 0(a0)    # print out
    add a1, a2, x0
    add a2, t0, x0
    jal fibonacci
