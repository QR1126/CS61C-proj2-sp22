.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

	# Prologue
	# store register value on the stack
	addi sp, sp, -24
	sw ra, 0(sp) 
	sw s0, 4(sp)  # s0 is used to store file descriptor return by fopen
	sw s1, 8(sp)  # s1 is used to store value in a1 and row number
	sw s2, 12(sp) # s2 is used to store value in a2 and col number
	sw s3, 16(sp) # s3 is used to store pointer to the matrix in memory
	sw s4, 20(sp) 

	add s1, a1, x0 # store the pointer
	add s2, a2, x0 # store the pointer

	# step 1: open the file with read permissions, we will use fopen
	# Arguments:
	#   a0 (char *) is the pointer to the filename string
	#   a1 (int)   is the permission bits. 0 for read-only, 1 for write-only
	# Returns:
	#   a0 (int)   A file descriptor. If opening the file failed, this value is -1
	add a1, x0, x0 # read permission
	jal fopen
	li t0, -1
	beq a0, t0, read_matrix_fopen_exception
	add s0, a0, x0 # store the file descriptor

	# step 2: Read the number of rows and columns from the file 
	# (remember: these are the first two integers in the file). 
	# Store these integers in memory at the provided pointers 
	# (a1 for rows and a2 for columns). we will use fread
	# Arguments:
	#   a0 (int)   is the file descriptor
	#   a1 (int *) is the pointer to the buffer where the read bytes will be stored
	#              The buffer should have been previously allocated with malloc
	#   a2 (int)   is the number of bytes to read from the file
	# Returns:
	#   a0 (int)   is the number actually read from the file. If this differs from the argument provided in a2, 
	#              then we either hit the end of the file or there was an error.
	# read row number
	add a0, s0, x0
	add a1, s1, x0
	addi a2, x0, 4
	jal fread
	li t0, 4
	bne a0, t0, read_matrix_fread_exception
	# read col number
	add a0, s0, x0
	add a1, s2, x0
	addi a2, x0, 4
	jal fread
	li t0, 4
	bne a0, t0, read_matrix_fread_exception

	lw s1, 0(s1) # now s1 store row number
	lw s2, 0(s2) # now s2 store col number

	# step 3: Allocate space on the heap to store the matrix. 
	# Arguments:
	#   a0 (int)    The size of the memory that we want to allocate (in bytes)
	# Returns:
	#   a0 (void *) A pointer to the allocated memory. If the allocation failed, this value is 0.
	mul a0, s1, s2
	slli a0, a0, 2
	jal malloc
	beq a0, x0, read_matrix_malloc_exception
	add s3, a0, x0

	# step 4: Read the matrix from the file to the memory allocated in the previous step
	mul t0, s1, s2
	li t1, 0 # i = 0
	mv s4, s3
loop_begin:
	add a0, s0, x0
	add a1, s4, x0
	li a2, 4
	addi sp, sp, -12
	sw t0, 0(sp)
	sw t1, 4(sp)
	sw a2, 8(sp)
	jal fread
	lw t0, 0(sp)
	lw t1, 4(sp)
	lw a2, 8(sp)
	addi sp, sp, 12
	bne a0, a2, read_matrix_fread_exception
	addi t1, t1, 1
	beq t1, t0, loop_end
	addi s4, s4, 4
	j loop_begin

loop_end:
	# Epilogue
	mv a0, s0
	jal fclose
	li t0, -1
	beq a0, t0, read_matrix_fclose_exception

	mv a0, s3
	lw ra, 0(sp) 
	lw s0, 4(sp)  # s0 is used to store file descriptor return by fopen
	lw s1, 8(sp)  # s1 is used to store value in a1 and row number
	lw s2, 12(sp) # s2 is used to store value in a2 and col number
	lw s3, 16(sp) # s3 is used to store pointer to the matrix in memory
	lw s4, 20(sp)
	addi sp, sp, 24
	ret

read_matrix_fopen_exception:
	li a0, 27
	j exit

read_matrix_fread_exception:
	li a0, 29
	j exit

read_matrix_malloc_exception:
	li a0, 26
	j exit

read_matrix_fclose_exception:
	li a0, 28
	j exit