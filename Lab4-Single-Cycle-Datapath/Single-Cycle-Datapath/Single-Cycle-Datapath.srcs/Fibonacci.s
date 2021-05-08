
.text
	addi s1, x0, 0x404 # ready (led[7]) address
	sw x0, 0(s1)       # not ready
    
	addi x1, x0, 1     # set x1 = 1
    
	addi a0, x0, 0x408 # out1 (seg) address
	addi s2, x0, 0x410 # valid (sw[5]) address
	
	sw x1, 0(s1)       # ready
loop1: 
	lw t0, 0(s2)       # check valid
	beq t0, x0, loop1
	
	sw x0, 0(s1)       # not ready
	
	addi s3, x0, 0x40C # in (sw[4:0]) address
	lw a1, 0(s3)       # get number 1 from in port
	sw a1, 0(a0)       # print number 1 into seg
	
	sw x1, 0(s1)       # ready
loop2: 
	lw t0, 0(s2)       # check valid
	beq t0, x0, loop2
	
	sw x0, 0(s1)       # not ready
	
	lw a2, 0(s3)       # get number 2 from in port
	sw a2, 0(a0)       # print number 2 into seg
	
fibonacci: # a0 --> output a1 --> numb1, a2 --> numb2
    add t0, a1, a2
    sw t0, 0(a0)       # print ans into seg
    add a1, a2, x0
    add a2, t0, x0
    jal fibonacci
