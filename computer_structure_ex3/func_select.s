# Noam Lahmani
.section .rodata
    charInput:   .string " %c"
    case31: .string "first pstring length: %d, second pstring length: %d\n"
    case32or33:       .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
    case35:       .string "length: %d, string: %s\n"
    case36:        .string "length: %d, string: %s\n"
    case37:         .string "compare result: %d\n"
    caseDefault:    .string "invalid option!\n"

    numInput:   .string "%d"

.section .rodata
    strL31:         .string "L0\n"
    strL32or33:         .string "L2\n"
    strL35:         .string "L3\n"
    strL36:         .string "L4\n"
    strL37:         .string "L5\n"
    strLD:          .string "LD\n"
    strLFinish:     .string "FINISH"

.align 8 # Align address to multiple of 8
.L: #jumping table
.quad .L0 # Case 31
.quad .L2 # Case 32
.quad .L2 # case 33
.quad .LD # Case 34: default
.quad .L3 # Case 35
.quad .L4 # Case 36
.quad .L5 # Case 37
.quad .LD #default


.text
.globl run_func
.type run_func, @function

run_func:
pushq   %rbp
movq    %rsp,               %rbp
sub     $640,              %rsp

 movq  %rsi, -8(%rbp)  # the address of the first pstring
 movq  %rdx, -16(%rbp) # the address of the second string

# Set up the jump table access
leaq -31(%rdi),%rsi # Compute xi = x-30
cmpq $10,%rsi # Compare xi:10
ja .LD # if >, goto default-case
jmp *.L(,%rsi,8) # Goto jumping table[xi]


# cases 31
.L0:

movq -8(%rbp), %rdi # rsi contain the first string, and %rdi is the first argument to pstrlen.
movq $0, %rax
call pstrlen
movq %rax, -24(%rbp)    # rax contain the string

movq -16(%rbp), %rdi       # second argument
movq $0, %rax
call pstrlen
movq %rax, -32(%rbp)

movq $case31, %rdi
movzbq -24(%rbp), %rsi
movzbq -32(%rbp), %rdx
movq $0, %rax
call printf

jmp .L9 # Goto done


# case 32 or 33
.L2:
  movq    $charInput,         %rdi
  movq    $0,               -24(%rbp)
  leaq    -24(%rbp),          %rsi    # old char, FIRST ARGUMENT
  movq    $0,                 %rax
  call    scanf

   movq    $charInput,        %rdi
   movq    $0,               -32(%rbp)
   leaq    -32(%rbp),         %rsi    # new char, SECOND ARGUMENT
   movq    $0,                %rax
   call    scanf

    movq   -8(%rbp),            %rdi
    movq   -24(%rbp),           %rsi
    movq   -32(%rbp),           %rdx
    call    replaceChar
    movq   %rax,                 -40(%rbp)

    movq  -16(%rbp),     %rdi
    movq   -24(%rbp),           %rsi
    movq   -32(%rbp),           %rdx
    call replaceChar
    movq   %rax, -48(%rbp)

    movq $case32or33, %rdi
    movzbq -24(%rbp), %rsi
    movzbq -32(%rbp), %rdx
    movq -40(%rbp), %rcx
    addq $1,    %rcx
    movq -48(%rbp), %r8
    addq $1,    %r8
    movq $0, %rax
    call printf



jmp .L9 # Goto done

# case 35
.L3:
 movq    $numInput,         %rdi
  movq    $0,               -24(%rbp)
  leaq    -24(%rbp),          %rsi    # first num - i
  movq    $0,                 %rax
  call    scanf

   movq    $numInput,        %rdi
   movq    $0,               -32(%rbp)
   leaq    -32(%rbp),         %rsi    # second num - j
   movq    $0,                %rax
   call    scanf

   movq -8(%rbp), %rdi
   movq -16(%rbp), %rsi
   movzbq -24(%rbp), %rdx
   movzbq -32(%rbp), %rcx
   movq $0, %rax
   call pstrijcpy

   movq $case35, %rdi
   movq   -8(%rbp), %rdx
   movzbq (%rdx), %rsi  # len 1
   addq $1, %rdx # string 1
   movq $0, %rax
   call printf

   movq $case35, %rdi
   movq -16(%rbp), %rdx
   movzbq (%rdx), %rsi  # len 2
   addq $1, %rdx # string 2
   movq $0, %rax
   call printf





jmp .L9 # Goto done


# case 36
.L4:
  movq -8(%rbp), %rdi
   movq $0, %rax
   call swapCase

  movq -16(%rbp), %rdi
   movq $0, %rax
   call swapCase

    movq $case36, %rdi
   movq -8(%rbp), %rdx
   movzbq (%rdx), %rsi
   addq $1, %rdx
   movq $0, %rax
   call printf

   movq $case36, %rdi
   movq -16(%rbp), %rdx
   movzbq (%rdx), %rsi
   addq $1, %rdx
   movq $0, %rax
   call printf


jmp .L9 # Goto done


# case 37
.L5:
  movq    $numInput,         %rdi
  movq    $0,               -24(%rbp)
  leaq    -24(%rbp),          %rsi    # first num - i
  movq    $0,                 %rax
  call    scanf

   movq    $numInput,        %rdi
   movq    $0,               -32(%rbp)
   leaq    -32(%rbp),         %rsi    # second num - j
   movq    $0,                %rax
   call    scanf

    movq -8(%rbp), %rdi
   movq -16(%rbp), %rsi
   movzbq -24(%rbp), %rdx
   movzbq -32(%rbp), %rcx
   movq $0, %rax
   call pstrijcmp

   movq $case37, %rdi
   movq %rax, %rsi
   movq $0, %rax
   call printf
jmp .L9 # Goto done

# case Default
.LD:
 movq $caseDefault, %rdi
 movq $0, %rax
call printf
jmp .L9 # Goto done

# case exit
.L9:
movq    $0,                 %rax
movq    %rbp,               %rsp
popq    %rbp

ret
