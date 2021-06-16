# COMP1521 Practice Prac Exam #1
# int rmOdd(int *src, int n, int*dest)

   .text
   .globl rmOdd

# params: src=$a0, n=$a1, dest=$a2
rmOdd:
# prologue
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)
   addi $sp, $sp, -4
   sw   $s0, ($sp)
   addi $sp, $sp, -4
   sw   $s1, ($sp)
   # if you need to save more $s? registers
   # add the code to save them here

# function body
# locals: s0 = src, s1 = dest 

	move $s0, $a0						# s0 = src
	move $s1, $a2						# s1 = dest
	li $t0, 0							# i = 0
	li $t1, 0							# j = 0
	li $t6, 2	
	for:
		bge $t0, $a1, endfor
		if:
			mul $t2, $t0, 4				# offset = i*4
			add $s0, $a0, $t2			# src[i]
			lw $s0, ($s0)
			div $s0, $t6					# src[i]%2
			mfhi $t3					# t3 = src[i]%2
			bnez $t3, endif	
			mul $t4, $t1, 4				# j offset = j*4
			add $s1, $a2, $t4
			sw $s0, ($s1)
			add $t1, $t1, 1				#j ++
		endif:
	add $t0, $t0, 1
	j for
	endfor:

	move $v0, $t1
	

# epilogue
   # if you saved more than two $s? registers
   # add the code to restore them here
   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $s0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra

