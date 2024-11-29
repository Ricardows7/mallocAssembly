.section .data
    I: .quad 0          # variável a
    A: .quad 0          # variável b
    msg: .asciz "Valor de a: "  # Mensagem inicial
    newline: .asciz "\n"  # Nova linha

.section .bss
    buf: .space 20      # Buffer para armazenar o número convertido

.section .text
.globl _start
_start:
    # Atribui 5 a 'I' (a) e 4 a 'A' (b)
    movq $5, I
    movq $4, A

    # Carregar os valores de 'I' (a) e 'A' (b) em registradores
    movq I, %rax     # Carrega o valor de 'I' (a) no registrador rax
    movq A, %rbx     # Carrega o valor de 'A' (b) no registrador rbx

    # Comparar 'a' (rax) com 'b' (rbx)
    cmpq %rbx, %rax  # Compara 'a' e 'b'

    # Se a <= b, pula para fim_if (equivalente ao else em C)
    jle fim_if

    # Se a > b, faz a = a + b
    addq %rbx, %rax  # a = a + b
    j fim            # Pula para fim

fim_if:
    # Se a <= b, faz a = a - b
    subq %rbx, %rax  # a = a - b

fim:
    # Escrever "Valor de a: " no terminal
    movq $1, %rax             # syscall: write
    movq $1, %rdi             # file descriptor: stdout
    movq $msg, %rsi           # endereço da mensagem
    movq $13, %rdx            # comprimento da mensagem
    syscall

    # Converter o valor de 'a' (armazenado em rax) para string
    movq %rax, %rdi           # Passar valor de 'a' para rdi
    movq $buf, %rsi           # Buffer para armazenar a string
    call int_to_string        # Chamar função para converter o número

    # Escrever o número convertido no terminal
    movq $1, %rax             # syscall: write
    movq $1, %rdi             # file descriptor: stdout
    movq $buf, %rsi           # endereço do buffer contendo o número
    movq $20, %rdx            # tamanho máximo do número
    syscall

    # Escrever uma nova linha
    movq $1, %rax             # syscall: write
    movq $1, %rdi             # file descriptor: stdout
    movq $newline, %rsi       # endereço da nova linha
    movq $1, %rdx             # comprimento da nova linha
    syscall

    # Saída do programa
    movq $60, %rax            # syscall: exit
    xor %rdi, %rdi            # código de saída 0
    syscall

# Função para converter um número em string
int_to_string:
    mov rcx, 10               # Divisor para base 10
    mov rbx, 0                # Inicializar rbx

convert_loop:
    xor rdx, rdx              # Limpar rdx para armazenar o resto
    div rcx                   # Dividir rax por 10, resultado em rax, resto em rdx
    add dl, '0'               # Converter o resto (dígito) em caractere ASCII
    dec rsi                   # Ir para o próximo caractere no buffer
    mov [rsi], dl             # Armazenar o dígito convertido
    inc rbx                   # Contar os dígitos
    test rax, rax             # Verificar se o quociente é 0
    jnz convert_loop          # Se não for 0, continuar convertendo

    # Ajustar ponteiro do buffer
    add rsi, rbx              # Ajustar rsi para o início da string

    ret

