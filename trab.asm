.section .bss
    topoInicialHeap       resq 1       ; Topo atual da heap
    inicioHeap     resq 1       ; Início da heap

.section .text
    global iniciaAlocador
    global finalizaAlocador
    extern brk
    
iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax             ; Syscall brk para obter topo da heap
    xorq %rdi, %rdi            ; Set %rdi = 0 para indicar topo corrente
    syscall

    movq %rax, [topoInicialHeap]      ; Armazena o endereço inicial no topo da heap
    movq %rax, [inicioHeap]    ; Armazena o endereço inicial no início da heap

    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax             ; Syscall brk para restaurar topo inicial
    movq [inicioHeap], %rdi
    syscall

    movq %rax, [topoInicialHeap]

    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rax            ; Recebe o endereço do bloco
    subq $16, %rax             ; Move para o campo de controle do bloco
    movq $0, (%rax)            ; Marca o bloco como livre

    popq %rbp
    ret

alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq [inicioHeap], %rdx      ; Ponteiro para o início da lista de blocos
    movq %rdi, %rcx              ; Tamanho do bloco solicitado
    movq $-1, %rsi               ; Variável para armazenar o endereço do bloco best fit encontrado
    movq $-1, %rbx               ; Armazena o menor tamanho de bloco que atende a solicitação

loop:
    cmpq $0, (%rdx)              ; Verifica se o bloco está livre
    jne proximo_bloco            ; Se ocupado, vai para o próximo bloco

    ; Verifica se o bloco livre é grande o suficiente
    movq 8(%rdx), %rax           ; Carrega o tamanho do bloco
    cmpq %rcx, %rax
    jl proximo_bloco             ; Se o bloco é menor que o solicitado, vai para o próximo

    ; Se é um bloco adequado, verifica se é o menor bloco até agora (best fit)
    cmpq %rbx, %rax              ; Compara com o menor bloco encontrado até agora
    jge proximo_bloco            ; Se for maior ou igual ao bloco encontrado, ignora
    movq %rax, %rbx              ; Atualiza o tamanho do menor bloco encontrado
    movq %rdx, %rsi              ; Atualiza o endereço do bloco best fit

proximo_bloco:
    addq 8(%rdx), %rdx           ; Avança para o próximo bloco
    addq $16, %rdx               ; Inclui espaço de controle
    cmpq %rdx, [topoInicialHeap]        ; Verifica se chegou ao final da lista
    jb loop                      ; Continua o loop se não for o fim

    ; Verifica se encontramos um bloco livre adequado (best fit)
    cmpq $-1, %rsi               ; Se %rsi ainda for -1, não encontrou bloco adequado
    jne achou_bloco              ; Se encontrou, pula para achou_bloco

    ; Se não encontrou um bloco livre, calcula o novo espaço em múltiplos de 4096 bytes
    movq %rcx, %rax              ; Move o tamanho solicitado para %rax
    addq $4095, %rax             ; Arredonda para o próximo múltiplo de 4096
    andq $-4096, %rax            ; Zera os últimos 12 bits para obter múltiplo de 4096

    ; Chama syscall brk para alocar o novo espaço arredondado
    movq $12, %rax
    movq [topoInicialHeap], %rdi
    addq %rax, %rdi              ; Incrementa o topo da heap com o espaço necessário
    syscall

    movq %rax, [topoInicialHeap]        ; Atualiza o topo da heap

    ; Configura o novo bloco alocado
    movq %rdx, %rsi              ; Ponteiro do novo bloco
    movq $1, (%rsi)              ; Define o bloco como ocupado
    movq %rcx, 8(%rsi)           ; Armazena o tamanho solicitado

    ; Retorna o endereço do bloco
    addq $16, %rsi
    movq %rsi, %rax
    jmp fim

achou_bloco:
    movq $1, (%rsi)              ; Marca o bloco best fit encontrado como ocupado
    addq $16, %rsi               ; Pula o controle para o bloco
    movq %rsi, %rax              ; Retorna o endereço do bloco

fim:
    popq %rbp
    ret
imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp

    movq [inicioHeap], %rbx
    loop:
        cmpq %rbx, [topoInicialHeap]
	jg fim
	//printa # para cada caractere de cabecalho
	movq //valor que indica o tamanho da area reservada para um registrador disponivel
	//passa por cada valor reservado printando + se estiver sendo usado e - se nao
	//atualiza %rbx
	j loop
    fim:
	popq %rbp
	ret
