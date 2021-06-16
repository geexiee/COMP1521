# COMP1521 Practice Prac Exam #1
# int lowerfy(char *src, char *dest)

   .text
   .globl lowerfy

# params: src=$a0, dest=$a1
lowerfy:
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
# locals: ...

	move $s0, $a0								# s0 = src
	move $s1, $a1								# s1 = dest
	li $t0, 0									# i = 0
	li $t1, 0									# n = 0
												# char c

	for:
		add $s0, $a0, $t0						# src[i]
		lb $s0, ($s0)							
		beqz $s0, endfor								# if src[i] == 0
		move $t2, $s0							# ch = src[i]
		if:
			blt $t2, 'A', endif						# break if ch < A
			bgt $t2, 'Z', endif						# break if ch > Z
			sub $t2, $t2, 'A'
			add $t2, $t2, 'a'
			add $t1, $t1, 1
		endif:
		add $s1, $a1, $t0
		lb $s1, ($t2)
		add $t0, $t0, 1
		j for
	endfor:
	
	add $s1, $a1, $t0
	li $s1, 0
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

