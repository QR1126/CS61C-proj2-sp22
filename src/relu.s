.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
	# Prologue
	addi t0, x0, 1
	blt a1, t0, exception
	j loop

loop:
	beq a1, x0, loop_end
	addi a1, a1, -1
	add t0, a0, x0
	lw t1, 0(a0)
	addi a0, a0, 4
	bge t1, x0, loop
	sw x0, 0(t0)
	j loop

exception:
	li a0, 36
	j exit

loop_end:
	# Epilogue
	ret
