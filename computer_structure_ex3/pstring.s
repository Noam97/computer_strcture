#318868312 Noam Lahmani

invalid: .string "invalid input!\n"

.text

    .globl pstrlen
    .type pstrlen, @function
pstrlen:
movzbq (%rdi), %rax
ret

  .globl replaceChar
    .type replaceChar, @function
replaceChar:
  pushq   %rbp
  movq    %rsp,              %rbp
  sub     $160,              %rsp

  movq  %rdi, -8(%rbp)  # the address of the ptr
  movq  %rsi, -16(%rbp) # old char
  movq  %rdx, -24(%rbp) # new char

  addq   $1, %rdi
  .Lreplace:
  cmpb $0, (%rdi)
    je .l_replace_finish
  movzbq    (%rdi),   %rax
  cmpb %al, -16(%rbp) # cmp old char to new
    je .l_replace
  addq   $1, %rdi
  jmp .Lreplace

  .l_replace:
  movzbq -24(%rbp), %rax
  movb %al, (%rdi) #  replace old char in new char
  addq   $1, %rdi
  jmp .Lreplace

  .l_replace_finish:
  movq    -8(%rbp),           %rax
  movq    %rbp,               %rsp
  popq    %rbp

  ret

    .globl pstrijcpy
      .type pstrijcpy, @function
  pstrijcpy:
  pushq   %rbp
  movq    %rsp,              %rbp
  sub     $160,              %rsp

  movq  %rdi, -8(%rbp) # the address of first pstring - dst
  movq  %rsi, -16(%rbp) # the address of second pstring - src
  movq $0, -24(%rbp)
  movb  %dl, -24(%rbp) # i
    movq $0, -32(%rbp)
  movb  %cl, -32(%rbp) # j

  cmpb %dl, %cl   # j-i
  js .l_pstrijcpy_invalid

  movzbq (%rdi), %rax   # len to rax
  subq $1, %rax  # len - 1 is the last index of the pstring
  cmpb %cl, %al
  js .l_pstrijcpy_invalid
  addq $1, %rdi
  addq $1, %rsi   # start of the string
  .l_pstrijcpy_loop:
  cmp %dl, %cl
  js .l_pstrijcpy_finish  # if i>j we finish
  leaq (%rdi, %rdx), %r8 # jump to the suitable index
  leaq (%rsi, %rdx), %r9 # jump to the suitable index
  movzbq (%r9), %rax
  movb %al, (%r8)
  addb $1, %dl # i++
  jmp .l_pstrijcpy_loop

  .l_pstrijcpy_invalid:
  movq $invalid, %rdi
  movq $0, %rax
  call printf
  jmp .l_pstrijcpy_finish


  .l_pstrijcpy_finish:
  movq    -8(%rbp),           %rax # change
  movq    %rbp,               %rsp
  popq    %rbp

  ret


  .globl swapCase
      .type swapCase, @function
  swapCase:
  pushq   %rbp
  movq    %rsp,              %rbp
  sub     $160,              %rsp

  movq  %rdi, -8(%rbp) # the address of pstring
  movq $0, %rdx

  .l_swap_loop:
  leaq (%rdi, %rdx), %r8 # jump to the suitable index
  cmpb $0, (%r8)
  js .l_swap_finish  # if i>j we finish
  cmpb $65, (%r8)
  js .l_swap_continue
  cmpb $123, (%r8)
  jns .l_swap_continue
  cmpb $97, (%r8)
  jns .l_swap_change_to_big

  cmpb $91, (%r8)
  js .l_swap_change_to_little
  addb $1, %dl # i++
  jmp .l_swap_loop

  .l_swap_change_to_little:
  leaq (%rdi, %rdx), %r8
  addb $32, (%r8)
  addb $1, %dl # i++
  jmp .l_swap_loop

  .l_swap_change_to_big:
  leaq (%rdi, %rdx), %r8
  subb $32, (%r8)
  addb $1, %dl # i++
  jmp .l_swap_loop

  .l_swap_continue:
  addb $1, %dl # i++
  jmp .l_swap_loop

  .l_swap_finish:
  movq    -8(%rbp),           %rax # change
  movq    %rbp,               %rsp
  popq    %rbp

  ret

  .globl pstrijcmp
      .type pstrijcmp, @function
  pstrijcmp:
  pushq   %rbp
  movq    %rsp,              %rbp
  sub     $160,              %rsp

  movq  %rdi, -8(%rbp) # the address of first pstring
  movq  %rsi, -16(%rbp) # the address of second pstring
  movq $0, -24(%rbp)
  movb  %dl, -24(%rbp) # i
    movq $0, -32(%rbp)
  movb  %cl, -32(%rbp) # j

  cmpb %dl, %cl   # j-i
  js .l_pstrijcmp_invalid

  movzbq (%rdi), %rax   # len to rax
  subq $1, %rax  # len - 1 is the last index of the pstring
  cmpb %cl, %al
  js .l_pstrijcmp_invalid
  addq $1, %rdi
  addq $1, %rsi   # start of the string
  .l_pstrijcmp_loop:
  cmp %dl, %cl
  js .l_pstrijcmp_return_0  # if i>j we finish
  leaq (%rdi, %rdx), %r8 # jump to the suitable index
  leaq (%rsi, %rdx), %r9 # jump to the suitable index
  movzbq (%r8), %rax
  cmpb %al, (%r9)
  js .l_pstrijcmp_return_1
  je l_pstrijcmp_continue
  jmp .l_pstrijcmp_return_minus_1

  .l_pstrijcmp_return_0:
  movq $0, %rax
  jmp .l_pstrijcmp_finish

  .l_pstrijcmp_return_minus_1:
  movq $-1, %rax
  jmp .l_pstrijcmp_finish


  .l_pstrijcmp_return_1:
  movq $1, %rax
  jmp .l_pstrijcmp_finish

  l_pstrijcmp_continue:
  addb $1, %dl # i++
  jmp .l_pstrijcmp_loop

  .l_pstrijcmp_invalid:
  movq $0, %rax
  movq $invalid, %rdi
  call printf
  movq $-2, %rax
  jmp .l_pstrijcmp_finish

  .l_pstrijcmp_finish:
  movq    %rbp,               %rsp
  popq    %rbp

  ret




