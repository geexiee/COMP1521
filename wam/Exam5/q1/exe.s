# COMP1521 Practice Prac Exam #1
# arrays

   .data

a1:
   .word   1, 2, 3, 4, 0, 0, 0, 0, 0, 0
a1N:
   .word   4
a2:
   .word   2, 3, 4, 5, 0, 0, 0, 0, 0, 0
a2N:
   .word   4

   .align  2
# COMP1521 Practice Prac Exam #1
# main program + show function

   .data
m1:
   .asciiz "a1 = "
m2:
   .asciiz "a2 = "
m3:
   .asciiz "dP = "
   .align  2

   .text
   .globl main
main:
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)

   la   $a0, a1
   lw   $a1, a1N
   la   $a2, a2
   lw   $a3, a2N
   jal  dotProd      # (dp,n) = dotProd(a1, a1N, a2, a2N)

   move $s0, $v0
   move $s1, $v1

   la   $a0, m1
   li   $v0, 4
   syscall           # printf("a1 = ")
   la   $a0, a1
   lw   $a1, a1N
   jal  showArray    # showArray(a1, a1N)

   la   $a0, m2
   li   $v0, 4
   syscall           # printf("a2 = ")
   la   $a0, a2
   lw   $a1, a2N
   jal  showArray    # showArray(a2, a2N)

   la   $a0, m3
   li   $v0, 4
   syscall           # printf("dP = ")
   move $a0, $s0
   move $a1, $s1
   jal  showPair     # showPair(dp,n)

   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra

# showArray(int *a, int n)
# params: a=$a0, n=$a1
# locals: a=$s0, n=$s1, i=$s2
showArray:
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)
   addi $sp, $sp, -4
   sw   $s0, ($sp)
   addi $sp, $sp, -4
   sw   $s1, ($sp)
   addi $sp, $sp, -4
   sw   $s2, ($sp)

   move $s0, $a0
   move $s1, $a1
   li   $s2, 0            # i = 0
show_for:
   bge  $s2, $s1, end_show_for

   move $t0, $s2
   mul  $t0, $t0, 4
   add  $t0, $t0, $s0
   lw   $a0, ($t0)
   li   $v0, 1            # printf("%d",a[i])
   syscall

   move $t0, $s2
   addi $t0, $t0, 1
   bge  $t0, $s1, incr_show_for
   li   $a0, ','
   li   $v0, 11           # printf(",")
   syscall

incr_show_for:
   addi $s2, $s2, 1       # i++
   j    show_for

end_show_for:
   li   $a0, '\n'
   li   $v0, 11
   syscall

   lw   $s2, ($sp)
   addi $sp, $sp, 4
   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $s0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra

# showPair(int dp, int n)
# params: dp=$a0, n=$a1
# locals: a=$s0, n=$s1, i=$s2
showPair:
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)
   addi $sp, $sp, -4
   sw   $s0, ($sp)
   addi $sp, $sp, -4
   sw   $s1, ($sp)

   move $s0, $a0
   move $s1, $a1

   li   $a0, '('
   li   $v0, 11
   syscall

   move $a0, $s0
   li   $v0, 1
   syscall

   li   $a0, ','
   li   $v0, 11
   syscall

   move $a0, $s1
   li   $v0, 1
   syscall

   li   $a0, ')'
   li   $v0, 11
   syscall
   li   $a0, '\n'
   li   $v0, 11
   syscall

   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $s0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra
# COMP1521 Practice Prac Exam #1
# (int dp, int n) dotProd(int *a1, int n1, int *a2, int n2)

   .text
   .globl dotProd

# params: a1=$a0, n1=$a1, a2=$a2, n2=$a3
dotProd:
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
#(int,int) dotProd(int *a1, int n1, int *a2, int n2)
#{
#   int i, len, sum = 0;
#   if (n1 < n2)
#      len = n1;
#   else
#      len = n2;
#  for (i = 0; i < len; i++) {
#      sum = sum + a1[i]*a2[i];
#   }
#   return (sum,len);
#}
   # add code for your dotProd function here
   
   move $t0, $a0    #t0 = a1
   move $t1, $a1    #t1 = n1
   move $t2, $a2    #t2 = a2
   move $t3, $a3    #t3 = n2
   li $t4, 0        #i = 0
   li $t5, 0        #sum = 0
   li $t6, 0        #len = 0
   
   
   if:
        bge $t1, $t3, else
        move $t6, $t1
        j endif
   else:
        move $t6, $t3
   endif:
   
   for:
        bge $t4, $t6, endfor        # jump to endfor if i>=len
        move $t9, $t4               #t9 = i
        
        mul $t9, $t9, 4             #offset = i*4
        add $t0, $a0, $t9           #t0 = a1[offset]
        lw $t0, ($t0)
        
        add $t2, $a2, $t9           #t2 = a2[offset]
        lw $t2, ($t2)
        
        mul $t7, $t0, $t2           #t7 = a1[offset]*a2[offset]
        add $t5, $t5, $t7           # sum = sum + t7
        
        add $t4, $t4, 1             #i++
        j for
   endfor:
    move $v0, $t5
    move $v1, $t6
        
    
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

