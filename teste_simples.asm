.section .data
    I: .quad 0    ; variável I (a)
    A: .quad 0    ; variável A (b)

.section .text
.globl _start
_start:
    ; Atribui os valores 5 e 4 para as variáveis I e A
    movq $5, %rax       ; Carregar valor 5 no registrador rax
    movq %rax, I        ; Armazenar o valor de rax em I
    movq $4, %rbx       ; Carregar valor 4 no registrador rbx
    movq %rbx, A        ; Armazenar o valor de rbx em A

    ; Move os valores de I e A para os registradores
    movq I, %rax        ; rax = I
    movq A, %rbx        ; rbx = A

    ; Compara rax (I) com rbx (A)
    cmpq %rbx, %rax     ; compara A com I

    ; Se I <= A, pula para fim_if
    jle fim_if

    ; Se I > A, soma A a I
    addq %rbx, %rax
    jmp fim

fim_if:
    ; Se I <= A, subtrai A de I
    subq %rbx, %rax

fim:
    ; Retorna o valor de I em %rdi para syscall exit
    movq %rax, %rdi     ; código de saída
    movq $60, %rax      ; syscall número 60 (sys_exit)
    syscall             ; faz a chamada de sistema para encerrar

