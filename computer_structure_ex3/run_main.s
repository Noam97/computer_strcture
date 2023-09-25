#318868312 Noam Lahmani
#I used my code from the last time I take this course
.section .rodata
    stringInput:   .string "%s"
    stringOutput:  .string "%s\n"

    numInput:   .string "%d"
    numOutput:  .string "%d\n"


    printrdi:   .string "%d\n"
    printrsi:   .string "%s\n"
    printrdx:   .string "%s\n"



.text
.globl run_main                         # run_main
    .type run_main, @function           # run_main
run_main:                                # run_main
    # ***************** - FIRST PSTRING - *****************
    #   allocate memory in the stack
    pushq   %rbp
    movq    %rsp,               %rbp
    sub     $1024,              %rsp

    #   scaning the first length of the first string
    movq    $numInput,          %rdi
    leaq    -257(%rbp),         %rsi    # first pstring, SECOND ARGUMENT
    movq    $0,                 %rax
    call    scanf

    leaq    -1024(%rbp),        %rsi
    movzbq  -257(%rbp),         %rcx
    movq    %rcx,               (%rsi)
    #   scaning the first string
    movq    $stringInput,       %rdi
    leaq    -256(%rbp),         %rsi
    movq    $0,                 %rax
    call    scanf

    leaq    -256(%rbp),         %rsi  # print 0
    movq    -1024(%rbp),        %rdx
    leaq    (%rdx,%rsi),        %rsi
    movb    $0,                 (%rsi)
    #   print the first string in the appropriate length
    leaq    -256(%rbp),         %rsi
    movq    $stringOutput,      %rdi
    movq    $0,                 %rax
   # call    printf


     # ***************** - SECOND PSTRING - *****************

         #   scaning the first length of the first string
    movq    $numInput,          %rdi
    leaq    -514(%rbp),         %rsi    # second pstring, THIRD ARGUMENT
    movq    $0,                 %rax
    call    scanf

    leaq    -1016(%rbp),        %rsi
    movzbq  -514(%rbp),         %rcx
    movq    %rcx,               (%rsi)
    movq    $stringInput,       %rdi
    leaq    -513(%rbp),         %rsi
    movq    $0,                 %rax
    call    scanf

    leaq    -513(%rbp),         %rsi  # print 0
    movq    -1016(%rbp),        %rdx
    leaq    (%rdx,%rsi),        %rsi
    movb    $0,                 (%rsi)

    leaq    -513(%rbp),         %rsi
    movq    $stringOutput,      %rdi
    movq    $0,                 %rax
   # call    printf


    # ***************** - OPTIOIN - *****************

    movq    $numInput,          %rdi
    movq    $0,                 -771(%rbp)
    leaq    -771(%rbp),         %rsi    # FIRST ARGUMENT
    movq    $0,                 %rax
    call    scanf



# ###### arguments to fun_selection
    movq -771(%rbp), %rdi  # first argument - option
    leaq -257(%rbp), %rsi  # second argument - second string
    leaq -514(%rbp), %rdx  # third argument - first string
    call run_func


    movq    $0,                 %rax
    movq    %rbp,               %rsp
    popq    %rbp

     ret





