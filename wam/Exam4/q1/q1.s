# COMP1521 Practice Prac Exam #1
# int novowels(char *src, char *dest)

   .text
   .globl novowels

# params: src=$a0, dest=$a1
novowels:
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

	move $s0, $a0
	move $t5, $a0
	move $s1, $a1
	li $t6, 0								# i = 0
	li $t1, 0								# j = 0
	li $t2, 0								# n = 0

	for:
		#sb $s0, ($t7)
		move $t7, $s0
		# calculate offset	
		add $t7, $a0, $t6					# src[i]
		lb $t7, ($t7)						
		beqz $t7, endfor					# if src[i] == 0, end loop

#		lb $t7, ($a0)
		move $a0, $t7						# t3 = ch = src[i]	
		jal isvowel
		move $a0, $t5
		beqz $v0, else
		add $t2, $t2, 1						# n++
		j endelse
#
		else:
			add $s1, $a1, $t1				# move by offset
			sb $t7, ($s1)
			add $t1, $t1, 1
		endelse:
#			
		add $t6, $t6, 1
		j for
	endfor:

	add $s1, $a1, $t6
	lb $s1, ($s1)
	li $s1, 0
	move $v0, $t2

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

#####

# auxiliary function
# int isvowel(char ch)
isvowel:
# prologue
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)

# function body
   li   $t0, 'a'
   beq  $a0, $t0, match
   li   $t0, 'A'
   beq  $a0, $t0, match
   li   $t0, 'e'
   beq  $a0, $t0, match
   li   $t0, 'E'
   beq  $a0, $t0, match
   li   $t0, 'i'
   beq  $a0, $t0, match
   li   $t0, 'I'
   beq  $a0, $t0, match
   li   $t0, 'o'
   beq  $a0, $t0, match
   li   $t0, 'O'
   beq  $a0, $t0, match
   li   $t0, 'u'
   beq  $a0, $t0, match
   li   $t0, 'U'
   beq  $a0, $t0, match

   li   $v0, 0
   j    end_isvowel
match:
   li   $v0, 1
end_isvowel:

# epilogue
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra
