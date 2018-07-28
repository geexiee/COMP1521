# COMP1521 18s2 Week 04 Lab
# Compute factorials, iterative function


### Global data

   .data
msg1:
   .asciiz "n  = "
msg2:
   .asciiz "n! = "
eol:
   .asciiz "\n"

### main() function
   .text
   .globl main
main:
   #  set up stack frame
   sw    $fp, -4($sp)       # push $fp onto stack
   la    $fp, -4($sp)       # set up $fp for this function
   sw    $ra, -4($fp)       # save return address
   sw    $s0, -8($fp)       # save $s0 to use as ... int n;
   addi  $sp, $sp, -12      # reset $sp to last pushed item

   #  code for main()
   li    $s0, 0             # n = 0;
   
   la    $a0, msg1
   li    $v0, 4
   syscall                  # printf("n  = ");

	li $v0, 5
	syscall
	move $s0, $v0

	la $a0, msg2
	li $v0, 4
	syscall

	move $a0, $s0
	jal fac
	
	move $a0, $v0
	li $v0, 1
	syscall
## ... rest of code for main() goes here ...
 
   la    $a0, eol
   li    $v0, 4
   syscall                  # printf("\n");

   # clean up stack frame
   lw    $s0, -8($fp)       # restore $s0 value
   lw    $ra, -4($fp)       # restore $ra for return
   la    $sp, 4($fp)        # restore $sp (remove stack frame)
   lw    $fp, ($fp)          # restore $fp (remove stack frame)

   li    $v0, 0
   jr    $ra                # return 0

# fac() function

fac:
   # setup stack frame
	sw $fp, -4($sp)
	la $fp, -4($sp)
	sw $ra, -4($fp)
	sw $s0, -8($fp)
	sw $s1, -12($fp)
	sw $s2, -16($fp)
	addi $sp, $sp, -20
## ... code for prologue goes here ...

   # code for fac()
	move $s0, $a0
	li $s2, 1
	li $s1, 1
	loop: 
		mul $s2, $s2, $s1
		addi $s1, 1
		bge $s0, $s1, loop
	end_loop:
	move $v0, $s2
## ... code for fac() goes here ...

   # clean up stack frame
	lw $s0, -8($fp)
	lw $ra, -4($fp)
	la $sp, 4($fp)
	lw $fp, ($fp)

## ... code for epilogue goes here ...
	jr $ra
