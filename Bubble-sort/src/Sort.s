# Bubble Sort 
#
# Ouedraogo Ezekiel B.
# 05/04/2021
#
# RISC V assembly (RV32IM)
#
# &array[i] --> address of array[i]
# *i --> i value (i is a pointer)
#

.data
	array:  .word 2,4,6,8,0,9,7,5,3,1
	size:	.word 10

.text
main:
	addi sp, sp, -12  # stack : make room for 3 items
	sw x10, 8(sp)     # save x10 on stack
	sw x11, 4(sp)     # save x11 on stack
	sw x12, 0(sp)     # save x12 on stack

	la x10, array     # load array adrress into x10
	lw x11, size	  # load array size into x11
	
	jal bubbleSort    # call Bubble Sort

	lw x12, 8(sp)	  # restore x12 from stack
	lw x11, 4(sp)     # restore x12 from stack
	lw x10, 0(sp)     # restore x12 from stack
	addi sp, sp, 8    # restore stack pointer

	j exit            # calling exit

bubbleSort:
	# x10 = array, x11 = size
	slli x11, x11, 2    # size = size * 4
	add x12, x10, x11   # x12 = &array[size]
	
	# from now (i and j are pointers)
    # x10 = i, x11 = j, x12 = &array[size]
loop1:
	bge x10, x12, exit1  # check i still in range

	addi x11, x10, 4         # j = i + 1

	addi sp, sp, -8          # stake : make room for 2 items
	sw x5, 4(sp)	         # save x5 on stack
	sw x6, 0(sp)	         # save x6 on stack
                             # x5 and x6 will be used inside loop2

loop2:

	bge x11, x12, exit2  # check j still in range

	lw x5, 0(x10)        # load i value
	lw x6, 0(x11)    	 # load j value
	ble x5, x6, exit3    # exit if *i <= *j
                         # else swap
	sw x6, 0(x10)
	sw x5, 0(x11)

exit3:
	addi x11, x11, 4    # j++
	jal loop2           # recursive call

exit2:
	lw x6, 0(sp)        # restore x6 from stack
	lw x5, 4(sp)        # restore x5 from stack
	addi sp, sp, 8      # restore stack pointer

	addi x10, x10, 4    # i++
	jal loop1           # recursive call

exit1:
	jalr x1  # return to calling routine

exit: