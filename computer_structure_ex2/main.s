#318868312 Noam Lahmani
	.data
id: .quad 318868312
true:       .string "True\n"
false:      .string "False\n"

    .section	.rodata			#read only data section
format1:	.string	"%d\n"

    .text
.global main
    .type main, @function

main:
    pushq %rbp #save the old frame pointer
    movq %rsp, %rbp #create the new frame pointer
    pushq %rbx #saving a callee save register.

    .L1:
    movq $format1, %rdi #the string is the first paramter passed to the printf function.
    movq $id, %rsi  #geting the address of label id
    movq (%rsi), %rsi #geting the id 
    movq $0, %rax
    call printf #calling to printf with its arguments

    .L2:
    movq id, %rbx   #save id in caller-save register
    movq $format1, %rdi  #the string is the first paramter passed to the printf function.
    movzbl %bh, %esi #get the second byte of id


    movq $format1, %rdi
    movzbl %bh, %esi    #get the second byte of id as the second parameter of printf function
    andl $1, %esi       #if the number is even %esi will contain 0, then 1

    cmpl $0, %esi    #if the second byte is even
    je .isEven  
    .isOdd:
    movl $3, %ecx # if the second byte is odd:
    imul id, %ecx   #  ecx contain the multiplication result of 3*id
    movl %ecx, %esi
    movq $format1, %rdi
    movq $0, %rax
    call printf
    jmp .L3

    .isEven:
    movl $0, %ecx
    movl $3, %ecx
    movl id, %eax
    cltd
    idivl %ecx
    movq $format1, %rdi
    movl %edx, %esi     #the modulu saved in rdx
    movq $0, %rax
    call printf

    .L3:
    movq id, %rbx
    movzbl %bl, %ecx    #the first byte of id

    movq %rbx, %r8     #save id in rdx
    shr $16, %r8       #access to the fourth and thirth bytes
    movzbq %dl, %r9    #acees to the thirth byte of id, (here it is the first byte)

    // movq $format1, %rdi #first argument to printf function
    xorq %r9, %rcx #xor between the first and the thirth bytes of the id
    cmpq $127, %rcx
    jg .isMore127 #if more then 127 then jump
   
    movl $false, %edi   #else - the xor result is less or equal to 127  
    movq $0, %rax
    call printf
    jmp .L4

    .isMore127:
    movl $true, %edi     
    movq $0, %rax
    call printf

    .L4:
    movq id, %rbx
    movzbl %bl, %ecx    #the first byte of id
    movq %rbx, %r8     #save id in rdx
    shr $24, %r8       #access to the fourth byte



    movq $0, %rcx #i
    movq $0, %rdx # k = couner of 1 in the binary number
    .Loop:
    cmpq $8, %rcx  #while i<8
    je .Done       #when i = 8 done
    movq %r8, %r9       #save tje fourth byte in %r9
    and $1, %r9         #check the lastes bit in %r9
    inc %rcx        #i++
    cmpq $1, %r9        
    jne .Loop       #if the lastes bit in %r9 is 0, go to the start of the loop
    inc %rdx           #else - k++
    shr $1, %r8     #shift to %r8 
    jmp .Loop

    .Done:
    movq $format1, %rdi
    movq %rdx, %rsi
    movq $0, %rax
    call printf

    movq	%rbp, %rsp	
	popq	%rbp		
	ret