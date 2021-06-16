# COMP1521 17s2 Final Exam
# void colSum(m, N, a)

   .text
   .globl colSum

# params: m=$a0, N=$a1, a=$a2
colSum:
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
   addi $sp, $sp, -4
   sw   $s2, ($sp)
   addi $sp, $sp, -4
   sw   $s3, ($sp)
   addi $sp, $sp, -4
   sw   $s4, ($sp)
   addi $sp, $sp, -4
   sw   $s5, ($sp)
   # if you need to save more than six $s? registers
   # add extra code here to save them on the stack

# suggestion for local variables (based on C code):
# m=#s0, N=$s1, a=$s2, row=$s3, col=$s4, sum=$s5

    move $s0, $a0                   # s0 = m
    move $s1, $a1                   # s1 = N
    move $s2, $a2                   # s2 = a
    li $s3, 0                       # row = 0
    li $s4, 0                       # col = 0
    li $s5, 0                       # sum = 0
    
    for1:
        bge $s4, $s1, endfor1
        li $s5, 0                   # sum = 0
        li $s3, 0
        for2:
            bge $s3, $s1, endfor2
            
            mul $t1, $s3, 16        # rowoffset = row * sizeofrow
            mul $t2, $s4, 4         # coloffset = col * 4
            add $t1, $t1, $t2       # total offset = sum of above offsets
            
            add $s0, $a0, $t1       # move m by offset
            lw $s0, ($s0)           # load m[row][col]
            add $s5, $s5, $s0       # sum = sum + m[row][col]

      
            add $s3, $s3, 1         # row++
            j for2
        endfor2:
        mul $t6, $s4, 4             # col offset = 4*col
        add $s2, $a2, $t6           # a[col]
        sw $s5, ($s2)               # a[col] = sum
        add $s4, $s4, 1             # col++
        j for1
    endfor1:

# epilogue
   # if you saved more than six $s? registers
   # add extra code here to restore them
   lw   $s5, ($sp)
   addi $sp, $sp, 4
   lw   $s4, ($sp)
   addi $sp, $sp, 4
   lw   $s3, ($sp)
   addi $sp, $sp, 4
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

