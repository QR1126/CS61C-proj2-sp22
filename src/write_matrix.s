.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

	# Prologue

	# Open the file with write permissions. The filepath is provided as an argument.
	# Write the number of rows and columns to the file. (Hint: The fwrite function expects a pointer to data in memory, so you should first store the data to memory, and then pass a pointer to the data to fwrite.)
	# Write the data to the file.
	# Close the file.
	addi sp, sp, -32
	sw ra, 0(sp) 
	sw s0, 4(sp)  
	sw s1, 8(sp)  
	sw s2, 12(sp) 
	sw s3, 16(sp) 
	sw s4, 20(sp) 
	sw s5, 24(sp)
	sw s6, 28(sp)

	add s1, a1, x0 # s1 store the pointer to the matrix in memory
	add s2, a2, x0 # s2 store the number of row
	add s3, a3, x0 # s3 store the number of col

	li a1, 1
	jal fopen
	li t0, -1
	beq a0, t0, write_matrix_fopen_exception
	add s0, a0, x0 # s0 store the fd

	# fwrite: Write bytes from a buffer in memory to a file. 
	# Subsequent writes append to the end of the existing file.
	# Arguments:
	#   a0 (int) 	fd
	#   a1 (void *) A pointer to a buffer containing what we want to write to the file
	#   a2 (int)    The number of elements to write to the file
	#   a3 (int)    The size of each element. In total, a2 × a3 bytes are written
	# Returns:
	#   a0 (int)    The number of items actually written to the file

	addi a0, a0, 4
	jal malloc
	beq a0, x0, write_matrix_malloc_exception
	mv s4, a0 # s4 store the pointer to a buffer that contain row number
	sw s2, 0(s4)

	addi a0, a0, 4
	jal malloc
	beq a0, x0, write_matrix_malloc_exception
	mv s5, a0 # s5 store the pointer to a buffer that contain col number
	sw s3, 0(s5)

	# write row number to the file
	add a0, s0, x0
	add a1, s4, x0
	li a2, 1
	li a3, 4
	jal fwrite
	li t0, 1
	bne a0, t0, write_matrix_fwrite_exception

	# write col number to the file
	add a0, s0, x0
	add a1, s5, x0
	li a2, 1
	li a3, 4
	jal fwrite
	li t0, 1
	bne a0, t0, write_matrix_fwrite_exception

	# write matrix data to the file
	mul t0, s2, s3
	add a0, s0, x0
	add a1, s1, x0
	add a2, t0, x0
	addi a3, x0, 4
	jal fwrite
	mul t0, s2, s3
	bne a0, t0, write_matrix_fwrite_exception

	# close the file
	add a0, s0, x0
	jal fclose
	li t0, -1
	beq a0, t0, write_matrix_fclose_exception

	# Epilogue
	lw ra, 0(sp) 
	lw s0, 4(sp)  
	lw s1, 8(sp)  
	lw s2, 12(sp) 
	lw s3, 16(sp) 
	lw s4, 20(sp) 
	lw s5, 24(sp)
	lw s6, 28(sp)
	addi sp, sp, 32
	ret

write_matrix_fopen_exception:
	li a0, 27
	j exit

write_matrix_malloc_exception:
	li a0, 26
	j exit

write_matrix_fwrite_exception:
	li a0, 30
	j exit

write_matrix_fclose_exception:
	li a0, 28
	j exit