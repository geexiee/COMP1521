#
# COMP1521 18s1 -- Assignment 1 -- Worm on a Plane!
#
# Base code by Jashank Jeremy and Wael Alghamdi
# Tweaked (severely) by John Shepherd
#
# Set your tabstop to 8 to make the formatting decent

# Requires:
#  - [no external symbols]

# Provides:
	.globl	wormCol
	.globl	wormRow
	.globl	grid
	.globl	randSeed

	.globl	main
	.globl	clearGrid
	.globl	drawGrid
	.globl	initWorm
	.globl	onGrid
	.globl	overlaps
	.globl	moveWorm
	.globl	addWormToGrid
	.globl	giveUp
	.globl	intValue
	.globl	delay
	.globl	seedRand
	.globl	randValue

	# Let me use $at, please.
	.set	noat

# The following notation is used to suggest places in
# the program, where you might like to add debugging code
#
# If you see e.g. putc('a'), replace by the three lines
# below, with each x replaced by 'a'
#
# print out a single character
# define putc(x)
# 	addi	$a0, $0, x
# 	addiu	$v0, $0, 11
# 	syscall
# 
# print out a word-sized int
# define putw(x)
# 	add 	$a0, $0, x
# 	addiu	$v0, $0, 1
# 	syscall

####################################
# .DATA
	.data
	.align 4
wormCol:	.space	40 * 4
	.align 4
wormRow:	.space	40 * 4
	.align 4
grid:		.space	20 * 40 * 1

randSeed:	.word	0
newline:   
    .asciiz "\n"

main__0:	.asciiz "Invalid Length (4..20)"
main__1:	.asciiz "Invalid # Moves (0..99)"
main__2:	.asciiz "Invalid Rand Seed (0..Big)"
main__3:	.asciiz "Iteration "
main__4:	.asciiz "Blocked!\n"

	# ANSI escape sequence for 'clear-screen'
main__clear:	.asciiz "\033[H\033[2J"
# main__clear:	.asciiz "__showpage__\n" # for debugging

giveUp__0:	.asciiz "Usage: "
giveUp__1:	.asciiz " Length #Moves Seed\n"

####################################
# .TEXT <main>
	.text
main:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4
# Uses: 	$a0, $a1, $v0, $s0, $s1, $s2, $s3, $s4
# Clobbers:	$a0, $a1

# Locals:
#	- `argc' in $s0
#	- `argv' in $s1
#	- `length' in $s2
#	- `ntimes' in $s3
#	- `i' in $s4

# Structure:
#	main
#	-> [prologue]
#	-> main_seed
#	  -> main_seed_t
#	  -> main_seed_end
#	-> main_seed_phi
#	-> main_i_init
#	-> main_i_cond
#	   -> main_i_step
#	-> main_i_end
#	-> [epilogue]
#	-> main_giveup_0
#	 | main_giveup_1
#	 | main_giveup_2
#	 | main_giveup_3
#	   -> main_giveup_common

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	sw	$s2, -20($sp)
	sw	$s3, -24($sp)
	sw	$s4, -28($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -28

	# save argc, argv
	add	$s0, $0, $a0
	add	$s1, $0, $a1

	# if (argc < 3) giveUp(argv[0],NULL);
	slti	$at, $s0, 4
	bne	$at, $0, main_giveup_0

	# length = intValue(argv[1]);
	addi	$a0, $s1, 4	# 1 * sizeof(word)
	lw	$a0, ($a0)	# (char *)$a0 = *(char **)$a0
	jal	intValue

	# if (length < 4 || length >= 40)
	#     giveUp(argv[0], "Invalid Length");
	# $at <- (length < 4) ? 1 : 0
	slti	$at, $v0, 4
	bne	$at, $0, main_giveup_1
	# $at <- (length < 40) ? 1 : 0
	slti	$at, $v0, 40
	beq	$at, $0, main_giveup_1
	# ... okay, save length
	add	$s2, $0, $v0

	# ntimes = intValue(argv[2]);
	addi	$a0, $s1, 8	# 2 * sizeof(word)
	lw	$a0, ($a0)
	jal	intValue

	# if (ntimes < 0 || ntimes >= 100)
	#     giveUp(argv[0], "Invalid # Iterations");
	# $at <- (ntimes < 0) ? 1 : 0
	slti	$at, $v0, 0
	bne	$at, $0, main_giveup_2
	# $at <- (ntimes < 100) ? 1 : 0
	slti	$at, $v0, 100
	beq	$at, $0, main_giveup_2
	# ... okay, save ntimes
	add	$s3, $0, $v0

main_seed:
	# seed = intValue(argv[3]);
	add	$a0, $s1, 12	# 3 * sizeof(word)
	lw	$a0, ($a0)
	jal	intValue

	# if (seed < 0) giveUp(argv[0], "Invalid Rand Seed");
	# $at <- (seed < 0) ? 1 : 0
	slt	$at, $v0, $0
	bne	$at, $0, main_giveup_3

main_seed_phi:
	add	$a0, $0, $v0
	jal	seedRand

	# start worm roughly in middle of grid

	# startCol: initial X-coord of head (X = column)
	# int startCol = 40/2 - length/2;
	addi	$s4, $0, 2
	addi	$a0, $0, 40
	div	$a0, $s4
	mflo	$a0
	# length/2
	div	$s2, $s4
	mflo	$s4
	# 40/2 - length/2
	sub	$a0, $a0, $s4

	# startRow: initial Y-coord of head (Y = row)
	# startRow = 20/2;
	addi	$s4, $0, 2
	addi	$a1, $0, 20
	div	$a1, $s4
	mflo	$a1

	# initWorm($a0=startCol, $a1=startRow, $a2=length)
	add	$a2, $0, $s2
	jal	initWorm

main_i_init:
	# int i = 0;
	add	$s4, $0, $0
main_i_cond:
	# i <= ntimes  ->  ntimes >= i  ->  !(ntimes < i)
	#   ->  $at <- (ntimes < i) ? 1 : 0
	slt	$at, $s3, $s4
	bne	$at, $0, main_i_end

	# clearGrid();
	jal	clearGrid

	# addWormToGrid($a0=length);
	add	$a0, $0, $s2
	jal	addWormToGrid

	# printf(CLEAR)
	la	$a0, main__clear
	addiu	$v0, $0, 4	# print_string
	syscall

	# printf("Iteration ")
	la	$a0, main__3
	addiu	$v0, $0, 4	# print_string
	syscall

	# printf("%d",i)
	add	$a0, $0, $s4
	addiu	$v0, $0, 1	# print_int
	syscall

	# putchar('\n')
	addi	$a0, $0, 0x0a
	addiu	$v0, $0, 11	# print_char
	syscall

	# drawGrid();
	jal	drawGrid

	# Debugging? print worm pos as (r1,c1) (r2,c2) ...

	# if (!moveWorm(length)) {...break}
	add	$a0, $0, $s2
	jal	moveWorm
	bne	$v0, $0, main_moveWorm_phi

	# printf("Blocked!\n")
	la	$a0, main__4
	addiu	$v0, $0, 4	# print_string
	syscall

	# break;
	j	main_i_end

main_moveWorm_phi:
	addi	$a0, $0, 1
	jal	delay

main_i_step:
	addi	$s4, $s4, 1
	j	main_i_cond
main_i_end:

	# exit (EXIT_SUCCESS)
	# ... let's return from main with `EXIT_SUCCESS' instead.
	addi	$v0, $0, 0	# EXIT_SUCCESS

main__post:
	# tear down stack frame
	lw	$s4, -24($fp)
	lw	$s3, -20($fp)
	lw	$s2, -16($fp)
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

main_giveup_0:
	add	$a1, $0, $0	# NULL
	j	main_giveup_common
main_giveup_1:
	la	$a1, main__0	# "Invalid Length"
	j	main_giveup_common
main_giveup_2:
	la	$a1, main__1	# "Invalid # Iterations"
	j	main_giveup_common
main_giveup_3:
	la	$a1, main__2	# "Invalid Rand Seed"
	# fall through
main_giveup_common:
	# giveUp ($a0=argv[0], $a1)
	lw	$a0, ($s1)	# argv[0]
	jal	giveUp		# never returns

####################################
# clearGrid() ... set all grid[][] elements to '.'
# .TEXT <clearGrid>
	.text
clearGrid:

# Frame:	$fp, $ra, $s0, $s1
# Uses: 	$s0, $s1, $t1, $t2
# Clobbers:	$t1, $t2

# Locals:
#	- `row' in $s0
#	- `col' in $s1
#	- `&grid[row][col]' in $t1
#	- '.' in $t2

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -16

	li $s0, 0										# row = 0
	li $s1, 0										# col = 0 - REDUNDANT
	li $t2, 46										# t2 = '.'	
                                                                                
	clearGrid_for_row:
		bge $s0, 20, clearGrid_end_for_row			# if row >= #rows, skip to end_for_row
		li $s1, 0									# s1 = col = 0
	    clearGrid_for_col:     
		    bge $s1, 40, clearGrid_end_for_col		# if col >= #cols, skip to end_for_col
		    mul $t3, $s0, 40						# t3 = row*size_of_row
		    mul $t4, $s1, 1							# t4 = col*sizeof(char)
		    add $t3, $t3, $t4						# t3 = offset = t3+t4 
		    sb $t2, grid($t3)						# grid[row][col] = '.'
		    addi $s1, $s1, 1					    # col++
		    j clearGrid_for_col
	    clearGrid_end_for_col:						         
		    addi $s0, $s0, 1						# row++
		    j clearGrid_for_row
	clearGrid_end_for_row:
													
	# tear down stack frame
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra
									

####################################
# drawGrid() ... display current grid[][] matrix
# .TEXT <drawGrid>
	.text
drawGrid:

# Frame:	$fp, $ra, $s0, $s1, $t1
# Uses: 	$s0, $s1
# Clobbers:	$t1

# Locals:
#	- `row' in $s0
#	- `col' in $s1
#	- `&grid[row][col]' in $t1

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -16


    li $s0, 0										# row = 0
    li $s1, 0										# col = 0 - REDUNDANT
													       
    drawGrid_for_row:
		bge $s0, 20, drawGrid_end_for_row			# if row >= nrows, skip to end_for_row
		li $s1, 0									# s1 = col = 0
	    drawGrid_for_col:    
		    bge $s1, 40, drawGrid_end_for_col		# if col >= ncols, skip to end_for_col
		    mul $t3, $s0, 40						# t3 = row*rowsize
		    mul $t4, $s1, 1							# t4 = col*sizeof(char)
		    add $t3 $t3, $t4						# t3 = offset = t3+t4
		    lb $t1, grid($t3)						# t1 = grid[row][col]
		    move $a0, $t1							# a0 = '.'				    	    
		    li $v0, 11                                  
		    syscall									# print '.'  
		    addi $s1, $s1, 1						# col++
		    j drawGrid_for_col
	    drawGrid_end_for_col:
		    la $a0, newline                         # a0 = '\n'    
		    li $v0, 4                                   
		    syscall									# print '\n'          
		    addi $s0, $s0, 1						# row++
		    j drawGrid_for_row
	drawGrid_end_for_row:

	# tear down stack frame
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# initWorm(col,row,len) ... set the wormCol[] and wormRow[]
#    arrays for a worm with head at (row,col) and body segements
#    on the same row and heading to the right (higher col values)
# .TEXT <initWorm>
	.text
initWorm:

# Frame:	$fp, $ra
# Uses: 	$a0, $a1, $a2, $t0, $t1, $t2
# Clobbers:	$t0, $t1, $t2

# Locals:
#	- `col' in $a0
#	- `row' in $a1
#	- `len' in $a2
#	- `newCol' in $t0
#	- `nsegs' in $t1
#	- temporary in $t2

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

	li $t1, 1						    # t1 = nsegs = 1
	addi $t0, $a0, 1                    # newCol = col + 1
	sw $a0, wormCol($0)					# wormCol[0] = col
	sw $a1, wormRow($0)					# wormRow[0] = row

	initWorm_for:
		bge $t1, $a2, initWorm_end	    # if nsegs > len, end loop
		beq $t0, 40, initWorm_end       # if newCol == ncols, end loop
		mul $t2, $t1, 4                 # offset = nsegs*4
		sw $t0, wormCol($t2)		    # wormCol[nsegs] = newCol
		addi $t0, $t0, 1                # newCol++
		sw $a1, wormRow($t2)		    # wormRow[nsegs] = row
		addi $t1, $t1, 1                # nsegs++
		j initWorm_for
	initWorm_end:

	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# ongrid(col,row) ... checks whether (row,col)
#    is a valid coordinate for the grid[][] matrix
# .TEXT <onGrid>
	.text
onGrid:

# Frame:	$fp, $ra
# Uses: 	$a0, $a1, $v0
# Clobbers:	$v0

# Locals:
#	- `col' in $a0
#	- `row' in $a1

# Code:


	# set up stack frame
    sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8
											
    onGrid_if:
        bltz $a0, onGrid_end1	   	# if col < 0, skip to end1
        bge $a0, 40, onGrid_end1    # if col >= 40, skip to end1 
        bltz $a1, onGrid_end1       # if row < 0, skip to end1
        bge $a1, 20 onGrid_end1     # if row >= nrows, skip to end1
        li $v0, 1					# all expressions true, return 1
        j onGrid_end2               # skip to end2 (so v0 remains as 1 and isnt changed to 0 by end1)
    onGrid_end1:
        li $v0, 0                   # expression is false, return 0
    onGrid_end2:

	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# overlaps(r,c,len) ... checks whether (r,c) holds a body segment
# .TEXT <overlaps>
	.text
overlaps:

# Frame:	$fp, $ra
# Uses: 	$a0, $a1, $a2
# Clobbers:	$t6, $t7

# Locals:
#	- `col' in $a0
#	- `row' in $a1
#	- `len' in $a2
#	- `i' in $t6

# Code:

	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8
																		                                    
    li $t0, 0							        # i = 0
    overlaps_for:
        bge $t0, $a2, end_overlaps_for          # if i >= len, skip to end_overlaps_for
        overlaps_if:
			mul $t3, $t0, 4						# offset = i * 4
			lw $t1, wormCol($t3)		        # t1 = wormcol[i]
			lw $t2, wormRow($t3)		        # t2 = wormrow[i]
            bne $t1, $a0, end_overlaps_if       # if wormcol[i] != col, skip to end of if statement
            bne $t2, $a1, end_overlaps_if       # if wormrow[i] != row, skip to end of if statement
            li $v0, 1					        # return 1
            j overlaps_end				        # skip to end so v0 remains as 1
		end_overlaps_if:
		addi $t0, $t0, 1				        # i++
		j overlaps_for					        # return to top of loop
	end_overlaps_for:
        li $v0, 0						        # worm does not overlap, return 0
    overlaps_end: 
    
	# tear down stack frame
    lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# moveWorm() ... work out new location for head
#         and then move body segments to follow
# updates wormRow[] and wormCol[] arrays

# (col,row) coords of possible places for segments
# done as global data; putting on stack is too messy
	.data
	.align 4
possibleCol: .space 8 * 4	# sizeof(word)
possibleRow: .space 8 * 4	# sizeof(word)

# .TEXT <moveWorm>
	.text
moveWorm:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7
# Uses: 	$s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $t0, $t1, $t2, $t3
# Clobbers:	$t0, $t1, $t2, $t3

# Locals:
#	- `col' in $s0
#	- `row' in $s1
#	- `len' in $s2
#	- `dx' in $s3
#	- `dy' in $s4
#	- `n' in $s7
#	- `i' in $t0
#	- tmp in $t1
#	- tmp in $t2
#	- tmp in $t3
# 	- `&possibleCol[0]' in $s5
#	- `&possibleRow[0]' in $s6

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	sw	$s2, -20($sp)
	sw	$s3, -24($sp)
	sw	$s4, -28($sp)
	sw	$s5, -32($sp)
	sw	$s6, -36($sp)
	sw	$s7, -40($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -40

	li $s7, 0						# n = 0
	li $s0, 0						# col = 0
	li $s1, 0						# row = 0
	move $s2, $a0				    # s2 = len
	li $s3, -1						# dx = -1
	li $s4, -1						# dy = -1
	la $s5, possibleCol				# s5 = &possibleCol[0]
	la $s6, possibleRow				# s6 = &possibleRow[0]
                
	moveWorm_for1:
		bgt $s3, 1, end_moveWorm_for1					# if dx > 1, end loop
		li $s4, -1										# dy = -1
		moveWorm_for2:		
			bgt, $s4, 1, end_moveWorm_for2		    	# if dy > 1, end loop
			    lw $t1, wormCol($0)                     # t1 = wormCol[0]                       
			    lw $t2, wormRow($0)                     # t2 = wormRow[0]
				add $s0, $t1, $s3				        # col = wormcol[0] + dx
				add $s1, $t2, $s4				        # row = wormRow[0] + dy 
				moveWorm_if:
				    move $a0, $s0                       # a0 = col
				    move $a1, $s1                       # a1 = row
					jal onGrid							# call onGrid
					nop
					beq $v0, 0, end_moveWorm_if			# if onGrid not true, end if statement
					move $a0, $s0
					move $a1, $s1
					move $a2, $s2                       # a2 = len
					jal overlaps						# call overlaps
					nop
					beq $v0, 1, end_moveWorm_if			# if overlaps true, end if statement
					mul $t3, $s7, 4                     # t3 = n*4 = offset
					sw $s0, possibleCol($t3)	        # possibleCol[n] = col
					sw $s1, possibleRow($t3)			# possibleRow[n] = row
					addi $s7, $s7, 1					# n++
				end_moveWorm_if:
			addi $s4, $s4, 1							# dy++
			j moveWorm_for2
		end_moveWorm_for2:
		addi $s3, $s3, 1								# dx++
		j moveWorm_for1
	end_moveWorm_for1:		
	
	beq $s7, 0, return0	                                # if n == 0, return 0
	sub $t0, $s2, 1										# i = len - 1
	moveWorm_for3:
	    ble $t0, 0, end_moveWorm_for3                   # if i <= 0, end loop
	    sub $t1, $t0, 1                                 # t1 = i - 1
        mul $t2, $t0, 4                                 # t2 = offset_i = i*4
	    mul $t3, $t1, 4                                 # t3 = offset_i-i = (i-1)*4
        lw $t4, wormRow($t3)                            # t4 = wormRow[i-1]
        sw $t4, wormRow($t2)                            # wormRow[i] = wormRow[i-1] 
        lw $t5, wormCol($t3)							# t5 = wormCol[i-1]
        sw $t5, wormCol($t2)							# wormCol[i] = wormCol[i-1]
        sub $t0, $t0, 1                                 # i--
        j moveWorm_for3	                      
    end_moveWorm_for3: 
    
    move $a0, $s7                                       # a0 = n
    jal randValue
    nop
    move $t0, $v0                                       # i = randValue(n)
	mul $t8, $t0, 4										# t8 = offset_i
    lw $t1, possibleRow($t8)                            # t1 = possibleRow[i]
    sw $t1, wormRow($0)									# wormRow[0] = possibleRow[i]
    lw $t2, possibleCol($t8)							# t2 = possibleCol[i]
    sw $t2, wormCol($0)									# wormCol[0] = possibleCol[i]
    li $v0, 1											# return 1
    j moveWorm_end
    
	return0:
	    li $v0, 0										# return 0
	    j moveWorm_end
	
	moveWorm_end: 
	
	# tear down stack frame
	lw	$s7, -36($fp)
	lw	$s6, -32($fp)
	lw	$s5, -28($fp)
	lw	$s4, -24($fp)
	lw	$s3, -20($fp)
	lw	$s2, -16($fp)
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)

	jr	$ra

####################################
# addWormTogrid(N) ... add N worm segments to grid[][] matrix
#    0'th segment is head, located at (wormRow[0],wormCol[0])
#    i'th segment located at (wormRow[i],wormCol[i]), for i > 0
# .TEXT <addWormToGrid>
	.text
addWormToGrid:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3
# Uses: 	$a0, $s0, $s1, $s2, $s3, $t1
# Clobbers:	$t1

# Locals:
#	- `len' in $a0
#	- `&wormCol[i]' in $s0
#	- `&wormRow[i]' in $s1
#	- `grid[row][col]'
#	- `i' in $t0

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	sw	$s2, -20($sp)
	sw	$s3, -24($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -24

    li $t4, '@'
    li $t5, 'o'
	la $s0, wormCol					            # s0 = &wormCol
	la $s1, wormRow					            # s1 = &wormRow
	li $t0, 1						            # i = 1

    lw $s2, wormRow($0)                         # s2 = row = wormRow[0]
    lw $s3, wormCol($0)                         # s3 = col = wormCol[0]
    mul $t2, $s2, 40                            # row_offset = row*sizeofrow
    add $t1, $t2, $s3                           # t1 = s2 + s3 = offset
    sb $t4, grid($t1)						    # grid[row][col] = '@'

    addWormToGrid_for:
        bge $t0, $a0, end_addWormToGrid_for		# if i >= len, skip to end of loop
		mul $t7, $t0, 4							# t7 = offset
	    lw $s2, wormRow($t7)                    # row = wormRow[i]
	    lw $s3, wormCol($t7)                    # col = wormCol[i]
	    mul $t2, $s2, 40						# t2 = row * sizeofrow
	    add $t1, $t2, $s3                       # offset = row*40 + col
	    sb $t5, grid($t1)                       # grid[row][col] = o
	    addi $t0, $t0, 1                        # i++
	    j addWormToGrid_for
	end_addWormToGrid_for: 

	# tear down stack frame
	lw	$s3, -20($fp)
	lw	$s2, -16($fp)
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

####################################
# giveUp(msg) ... print error message and exit
# .TEXT <giveUp>
	.text
giveUp:

# Frame:	frameless; divergent
# Uses: 	$a0, $a1
# Clobbers:	$s0, $s1

# Locals:
#	- `progName' in $a0/$s0
#	- `errmsg' in $a1/$s1

# Code:
	add	$s0, $0, $a0
	add	$s1, $0, $a1

	# if (errmsg != NULL) printf("%s\n",errmsg);
	beq	$s1, $0, giveUp_usage

	# puts $a0
	add	$a0, $0, $s1
	addiu	$v0, $0, 4	# print_string
	syscall

	# putchar '\n'
	add	$a0, $0, 0x0a
	addiu	$v0, $0, 11	# print_char
	syscall

giveUp_usage:
	# printf("Usage: %s #Segments #Moves Seed\n", progName);
	la	$a0, giveUp__0
	addiu	$v0, $0, 4	# print_string
	syscall

	add	$a0, $0, $s0
	addiu	$v0, $0, 4	# print_string
	syscall

	la	$a0, giveUp__1
	addiu	$v0, $0, 4	# print_string
	syscall

	# exit(EXIT_FAILURE);
	addi	$a0, $0, 1 # EXIT_FAILURE
	addiu	$v0, $0, 17	# exit2
	syscall
	# doesn't return

####################################
# intValue(str) ... convert string of digits to int value
# .TEXT <intValue>
	.text
intValue:

# Frame:	$fp, $ra
# Uses: 	$t0, $t1, $t2, $t3, $t4, $t5
# Clobbers:	$t0, $t1, $t2, $t3, $t4, $t5

# Locals:
#	- `s' in $t0
#	- `*s' in $t1
#	- `val' in $v0
#	- various temporaries in $t2

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

	# int val = 0;
	add	$v0, $0, $0

	# register various useful values
	addi	$t2, $0, 0x20 # ' '
	addi	$t3, $0, 0x30 # '0'
	addi	$t4, $0, 0x39 # '9'
	addi	$t5, $0, 10

	# for (char *s = str; *s != '\0'; s++) {
intValue_s_init:
	# char *s = str;
	add	$t0, $0, $a0
intValue_s_cond:
	# *s != '\0'
	lb	$t1, ($t0)
	beq	$t1, $0, intValue_s_end

	# if (*s == ' ') continue; # ignore spaces
	beq	$t1, $t2, intValue_s_step

	# if (*s < '0' || *s > '9') return -1;
	blt	$t1, $t3, intValue_isndigit
	bgt	$t1, $t4, intValue_isndigit

	# val = val * 10
	mult	$v0, $t5
	mflo	$v0

	# val = val + (*s - '0');
	sub	$t1, $t1, $t3
	add	$v0, $v0, $t1

intValue_s_step:
	# s = s + 1
	addi	$t0, $t0, 1	# sizeof(byte)
	j	intValue_s_cond
intValue_s_end:

intValue__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

intValue_isndigit:
	# return -1
	addi	$v0, $0, -1
	j	intValue__post

####################################
# delay(N) ... waste some time; larger N wastes more time
#                            makes the animation believable
# .TEXT <delay>
	.text
delay:

# Frame:	$fp, $ra
# Uses: 	$a0
# Clobbers:	$t0, $t1, $t2

# Locals:
#	- `n' in $a0
#	- `x' in $f6
#	- `i' in $t0
#	- `j' in $t1
#	- `k' in $t2

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8
									
    li.s $f6, 3.0                       # x = 3
    li.s $f7, 3.0                       # f7 = 3
    li $t0, 0                           # i = 0
    li $t1, 0                           # j = 0
    li $t2, 0                           # k = 0

    fori: 
        bge $t0, $a0, end_fori          # if i >= n, skip to end_fori
        forj:
            bge $t1, 20000, end_forj    # if j >= 20 000, skip to end_forj (number reduced from 40 000 to pass autotests)
            fork:
                bge $t2, 15, end_fork   # if k >= 15, skip to end_fork (number reduced from 1000 to pass autotests)
                mul.s $f6, $f6, $f7     # x = x * 3
                addi $t2, $t2, 1        # k++
                j fork
            end_fork:
        addi $t1, $t1, 1                # j++
        j forj
        end_forj:
    addi $t0, $t0, 1					# i++
    j fori
    end_fori:
            
     
     
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# seedRand(Seed) ... seed the random number generator
# .TEXT <seedRand>
	.text
seedRand:

# Frame:	$fp, $ra
# Uses: 	$a0
# Clobbers:	[none]

# Locals:
#	- `seed' in $a0

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

	# randSeed <- $a0
	sw	$a0, randSeed

seedRand__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

####################################
# randValue(n) ... generate random value in range 0..n-1
# .TEXT <randValue>
	.text
randValue:

# Frame:	$fp, $ra
# Uses: 	$a0
# Clobbers:	$t0, $t1

# Locals:	[none]
#	- `n' in $a0

# Structure:
#	rand
#	-> [prologue]
#       no intermediate control structures
#	-> [epilogue]

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

	# $t0 <- randSeed
	lw	$t0, randSeed
	# $t1 <- 1103515245 (magic)
	li	$t1, 0x41c64e6d

	# $t0 <- randSeed * 1103515245
	mult	$t0, $t1
	mflo	$t0

	# $t0 <- $t0 + 12345 (more magic)
	addi	$t0, $t0, 0x3039

	# $t0 <- $t0 & RAND_MAX
	and	$t0, $t0, 0x7fffffff

	# randSeed <- $t0
	sw	$t0, randSeed

	# return (randSeed % n)
	div	$t0, $a0
	mfhi	$v0

rand__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

