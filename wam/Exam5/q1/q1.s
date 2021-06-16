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

