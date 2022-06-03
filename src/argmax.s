.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	# Prologue
	addi t0, x0, 1
	blt a1, t0, exception
	addi t0, x0, 0 # t0 is the index
	add a2, x0, x0 # a2 is the index of largest element
	lw t1, 0(a0)   # t1 is the largest element
	j loop

loop:
	beq a1, x0, loop_end 
	lw t2, 0(a0)
	addi a0, a0, 4
	addi a1, a1, -1
	add t3, t0, x0
	addi t0, t0, 1
	bge t1, t2, loop
	add t1, t2, x0
	add a2, t3, x0
	j loop

exception:
	li a0, 36
	j exit

loop_end:
	# Epilogue
	add a0, a2, x0
	ret
