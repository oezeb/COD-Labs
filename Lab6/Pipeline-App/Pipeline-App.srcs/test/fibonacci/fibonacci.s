# finonacci
# test auipc, blt and bge
.data
num0: .word 1
num1: .word 2

.text
	lw a0, num0
	sw a0, 0x408(x0)
	
	lw a1, num1
	sw a1, 0x408(x0)
	
fibonacci:
	blt a0, a1, less
	bge a0, a1, great
less:
	add a0, a0, a1
	sw a0, 0x408(x0)
	jal fibonacci
great:
	add a1, a1, a0
	sw a1, 0x408(x0)
	jal fibonacci