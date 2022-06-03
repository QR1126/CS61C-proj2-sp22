.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
	# Prologue
	addi t0, x0, 1
	blt a2, t0, exception1
	beq a0, x0, exception1
	blt a3, t0, exception2
	blt a4, t0, exception2
	li t0, 4
	add t1, x0, x0 # t1 store the result
	j loop_start

exception1:
	li a0, 36
	j exit

exception2:
	li a0, 37
	j exit

loop_start:
	beq a2, x0, loop_exit
	addi a2, a2, -1
	lw t2, 0(a0)
	lw t3, 0(a1)
	mul t4, t2, t3
	add t1, t1, t4
	mul t5, t0, a3
	mul t6, t0, a4
	add a0, a0, t5
	add a1, a1, t6
	j loop_start

loop_exit:
	add a0, t1, x0
	ret




