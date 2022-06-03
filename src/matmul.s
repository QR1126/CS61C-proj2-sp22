.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

	# Error checks
	addi t0, x0, 1
	blt a1, t0, exception_matmul
	blt a2, t0, exception_matmul
	blt a4, t0, exception_matmul
	blt a5, t0, exception_matmul
	bne a2, a4, exception_matmul

	# Prologue
	li t0, 0 # t0 is the index of i
	li t1, 0 # t1 is the index of j
	li t2, 0 # t2 is the index of mat d

	# calling convention: callee save
	addi sp, sp, -8
	sw s0, 0(sp)
	sw s1, 4(sp)
	add s0, a3, x0 # store the start of m1
	add s1, a6, x0 # store the start of mat d

outer_loop_start:
	beq t0, a1, outer_loop_end # mat finish
	
	addi sp, sp, -4
	sw ra, 0(sp)
	jal inner_loop_start 
	lw ra, 0(sp)
	addi sp, sp, 4
	
	addi t0, t0, 1 # i++
	li t3, 4 # update the pointer to m0
	mul t3, t3, a2
	add a0, a0, t3 
	add a3, s0, x0 # j = 0
	li t1, 0
	j outer_loop_start

inner_loop_start:
	beq t1, a5, inner_loop_end

	# calling convention
	addi sp, sp, -48
	sw a0, 0(sp)
	sw a1, 4(sp)
	sw a2, 8(sp)
	sw a3, 12(sp)
	sw a4, 16(sp)
	sw a5, 20(sp)
	sw a6, 24(sp)
	sw ra, 28(sp)
	sw t0, 32(sp)
	sw t1, 36(sp)
	sw t2, 40(sp)
	sw t3, 44(sp)	

	# init arguments for dot
	add a1, a3, x0
	addi a3, x0, 1
	add a4, a5, x0 
	
	jal dot
	sw a0, 0(s1) # store the result of mat d(i, j)

	# reload value 
	lw a0, 0(sp)
	lw a1, 4(sp)
	lw a2, 8(sp)
	lw a3, 12(sp)
	lw a4, 16(sp)
	lw a5, 20(sp)
	lw a6, 24(sp)
	lw ra, 28(sp)
	lw t0, 32(sp)
	lw t1, 36(sp)
	lw t2, 40(sp)
	lw t3, 44(sp)
	addi sp, sp, 48

	addi t2, t2, 1 # update index of mat d
	slli t4, t2, 2 # update byte location of m d
	add s1, a6, t4

	addi t1, t1, 1 # j++	
	addi a3, a3, 4 # update byte location of m1
	j inner_loop_start

exception_matmul:
	li a0, 38
	j exit

inner_loop_end:
	jr ra

outer_loop_end:
	# Epilogue
	lw s0, 0(sp)
	lw s1, 4(sp)
	addi sp, sp, 8
	ret
