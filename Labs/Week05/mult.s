# COMP1521 18s1 Week 05 Lab
#
# void multMatrices(int n, int m, int p,
#                   int A[n][m], int B[m][p], int C[n][p])
# {
#    for (int r = 0; r < n; r++) {
#       for (int c = 0; c < p; c++) {
#          int sum = 0;
#          for (int i = 0; i < m; i++) {
#             sum += A[r][i] * B[i][c];
#          }
#          C[r][c] = sum;
#       }
#    }
# }

   .text
   .globl multMatrices
multMatrices:
   # possible register usage:
   # n is $s0, m is $s1, p is $s2,
   # r is $s3, c is $s4, i is $s5, sum is $s6	
   # set up stack frame for multMatrices()
   # set up stack frame for multMatrices()
   sw    $fp, -4($sp)
   la    $fp, -4($sp)
   sw    $ra, -4($fp)
   sw    $s0, -8($fp) #n
   sw    $s1, -12($fp)#m
   sw    $s2, -16($fp)#p
   sw    $s3, -20($fp)#r
   sw    $s4, -24($fp)#c
   sw    $s5, -28($fp)#i
   sw    $s6, -32($fp)#sum
   addi  $sp, $sp, -36
   # implement above C code
   move $s0, $a0 #n
   move $s1, $a1 #m
   move $s2, $a2 #p
   #print
   li $v0, 1
   li $a0, 1
   #syscall
   li    $s3, 0                  #r = 0
   for_col:
    li    $s4, 0                 #c = 0
    #print
    li $v0, 1
    li $a0, 2
    #syscall
    bge   $s3, $s0, end_for_col    #if r >= n, end for_col
    for_row:
     li    $s5, 0                #i = 0
     li    $s6, 0                #sum = 0
     #print
     li    $v0, 1
     li    $a0, 3
     #syscall
     bge   $s4, $s2, end_for_row   #if c >= p, end for_row
     
     lw $t5, 4($fp)  #t5 = C
     for_i:
      #print
      li    $v0, 1
      li    $a0, 4
      #syscall
      bge $s5, $s1, end_for_i    #if i >= m, end for_i
      lw  $t0,12($fp) #t0 = A
      lw  $t1, 8($fp) #t1 = B

      #mul $t2, $s3, $s5#r*i
      mul $t2, $s3, $s1#r*m
      add $t2, $t2, $s5#r*m + i
      mul $t2, $t2, 4  #(r*m+i)*4
      add $t0, $t0, $t2#shift A
      lw  $t0, ($t0)

      #mul $t3, $s5, $s4#i*c
      mul $t3, $s5, $s2#i*p
      add $t3, $t3, $s4#i*p + c 
      mul $t3, $t3, 4  #(i*p + c)*4
      add $t1, $t1, $t3#shift B
      lw  $t1, ($t1)   #load t1

      mul $t4, $t0, $t1     #mul, t4 =  A[r][i] * B[i][c]
                            #           A[n][m],  B[m][p], C[n][p]
      add $s6, $s6, $t4     #add to sum
      addi $s5, 1                #i++
      #print
      li $v0, 1
      move $a0, $s6
      #syscall
      li $a0, 32
      li $v0, 11 
      #syscall
      j for_i
     end_for_i:
     mul $t6, $s3, $s2 #r*p
     add $t6, $t6, $s4 #r*p + c
     mul $t6, $t6, 4   #(r*p + c)*4
     add $t5, $t5, $t6 #shift C by 4*r*c
     #lw  $t6, ($t5)    #get value at t5 (C[r][c])
     #add $t6, $t6, $s6

     #PRINT
     move $a0, $s6
     li $v0, 1
     #syscall
     li $v0, 11
     li $a0, 32
     #syscall 
     sw $s6, ($t5)
     addi $s4, 1                 #c++
     j for_row
    end_for_row:
    #print
    li $a0, 7
   li $v0, 1
   #syscall
   addi $s3, 1                  #r++
   j for_col
   end_for_col:
   #print
   li $a0, 8
   li $v0, 1
   #syscall
   # clean up stack and return
   lw    $ra, -4($fp)
   lw    $s0, -8($fp)
   lw    $s1, -12($fp)
   lw    $s2, -16($fp)
   lw    $s3, -20($fp)
   lw    $s4, -24($fp)
   lw    $s5, -28($fp)
   lw    $s6, -32($fp)
   la    $sp, 4($fp)
   lw    $fp, ($fp)
   jr    $ra
