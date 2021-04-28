.data
led: .word 0xff 	# all leds on

.text
	la a0, led
main:
	beq x0, x0, test
	jal exit           

test:
	lw a1, 0(a0)       # load 0xff
	
	sw x0, 0(a0) 		# test sw, lw, beq all leds off

	addi t0, x0, 0x1 	# test addi
	sw t0, 0(a0)        # one led on

	add t0, x0, a1      # test add and lw
	sw t0, 0(a0)        # all leds on
	
	jal exit            # test jal

	sw x0, 0(a0) 		# all leds off
	
exit: