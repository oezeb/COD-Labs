.text
    # initially all leds are on
	addi a0, x0, 0x400 # out0 (led[4:0]) address
    addi x1, x0, 0xf
	sw x1, 0(a0)       # test addi, sw: 4 leds on (8'b0000_1111)
    sw x1, 0(x0)
main:
	beq x1, x1, test
	jal exit

test:
	sw x0, 0(a0)       # test beq: all leds off

	lw a1, 0(x0)       # load 0xf
	sw a1, 0(a0)       # test: lw: 4 leds on (8'b0000_1111)

	add a1, a1, a1     # a1 = 0xf + 0xf = 0x1e
	sw a1, 0(a0)       # test add: 4 leds on (8'b0001_1110)
	
	jal exit

	sw x0, 0(a0) 		# test jal: all leds off
	
exit:
