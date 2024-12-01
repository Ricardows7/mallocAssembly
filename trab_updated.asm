.section .bss
	.lcomm topoInicialHeap, 8	#Topo da heap
    .lcomm inicioHeap, 8	#Base da heap

.section .text
.global iniciaAlocador
.global finalizaAlocador
.global liberaMem
.global alocaMem
.global imprimeMapa

.extern brk

.section .data                                                                  
vazio: .asciz "<vazio>"  
caractere: .byte 0
charLivre: .byte '-'
charOcupado: .byte '+'
charCabecalho: .byte '#'

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax             # Syscall brk para obter topo da heap
    xorq %rdi, %rdi            # Set %rdi = 0 para indicar topo corrente
    syscall

    movq %rax, [topoInicialHeap]      # Armazena o endereço inicial no topo da heap
    movq %rax, [inicioHeap]    # Armazena o endereço inicial no início da heap

    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax             # Syscall brk para restaurar topo inicial
    movq [inicioHeap], %rdi
    syscall

    movq %rax, [topoInicialHeap] #?

    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rax            # Recebe o endereço do bloco
    subq $16, %rax             # Move para o campo de controle do bloco
    movq $0, (%rax)            # Marca o bloco como livre

	movq $0, %rax			   #Valor de retorno

    popq %rbp
    ret

alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq [inicioHeap], %rdx      # Ponteiro para o início dos blocos
    movq %rdi, %rcx              # Tamanho do bloco solicitado
    movq $-1, %rsi               # Endereço do bloco best fit
    movq $-1, %rbx               # Menor tamanho de bloco

loop:
    cmpq $0, (%rdx)              # Verifica se o bloco está livre
    jne proximo_bloco            # Se ocupado, vai para o próximo bloco

    # Verifica se o bloco livre é grande o suficiente
    movq 8(%rdx), %rax           # Carrega o tamanho do bloco
    cmpq %rcx, %rax
    jl proximo_bloco             # Se o bloco é menor que o solicitado, vai para o próximo

    # Se é um bloco adequado, verifica se é o menor bloco até agora (best fit)
    cmpq %rbx, %rax              # Compara com o menor bloco encontrado até agora
    jge proximo_bloco            # Se for maior ou igual ao bloco encontrado, ignora
    movq %rax, %rbx              # Atualiza o tamanho do menor bloco encontrado
    movq %rdx, %rsi              # Atualiza o endereço do bloco best fit

proximo_bloco:
    addq 16(%rdx), %rdx           # Avança para o próximo bloco
    addq $16, %rdx               # Inclui espaço de controle
    cmpq %rdx, [topoInicialHeap]        # Verifica se chegou ao final da lista
    jb loop                      # Continua o loop se não for o fim

    # Verifica se encontramos um bloco livre adequado (best fit)
    cmpq $-1, %rsi               # Se %rsi ainda for -1, não encontrou bloco adequado
    jne achou_bloco              # Se encontrou, pula para achou_bloco

    # Se não encontrou um bloco livre, calcula o novo espaço em múltiplos de 4096 bytes
    movq %rcx, %rax              # Move o tamanho solicitado para %rax
    addq $4095, %rax             # Arredonda para o próximo múltiplo de 4096
    andq $-4096, %rax            # Zera os últimos 12 bits para obter múltiplo de 4096

    # Chama syscall brk para alocar o novo espaço arredondado
    movq $12, %rax
    movq [topoInicialHeap], %rdi
    addq %rax, %rdi              # Incrementa o topo da heap com o espaço necessário
    syscall

    movq %rax, [topoInicialHeap]        # Atualiza o topo da heap

    # Configura o novo bloco alocado
    movq %rdx, %rsi              # Ponteiro do novo bloco
    movq $1, (%rsi)              # Define o bloco como ocupado
    movq %rcx, 8(%rsi)           # Armazena o tamanho solicitado

    # Retorna o endereço do bloco
    addq $16, %rsi
    movq %rsi, %rax
    jmp fim

achou_bloco:
    movq $1, (%rsi)              # Marca o bloco best fit encontrado como ocupado
    addq $16, %rsi               # Pula o controle para o bloco
    movq %rsi, %rax              # Retorna o endereço do bloco

fim:
    popq %rbp
    ret

imprimeMapa:                                                                    
    pushq   %rbp                                                                
    movq    %rsp, %rbp                                                          
                                                                                
    movq    inicioHeap, %rbx        # Carrega o início da heap                  
    movq    topoInicialHeap, %r10   # Carrega o topo inicial da heap            
                                                                                
    movq    $0, %rcx                # Flag para indicar se a heap está completamente liberada
                                                                                
loopMapa:                                                                       
    cmpq    %rbx, %r10              # Verifica se chegou ao topo da heap        
    jge     verificaVazio           # Sai do loop se %rbx >= %r10               
                                                                                
    # Imprime o cabeçalho do nó                                                 
    movq    %rbx, %rdi              # Endereço atual do bloco                   
    call    imprimeCabecalho        # Imprime os bytes do cabeçalho como '#'    
                                                                                
    # Verifica o estado do bloco                                                
    movq    8(%rbx), %rax           # Carrega o tamanho do bloco (do cabeçalho) 
    movb    (%rbx), %r8b            # Carrega o primeiro byte da área de dados  
    addq    $16, %rbx               # Move o ponteiro %rbx para a área de dados do bloco (16 bytes para cabeçalho)
                                                                                
    movq    %rax, %rsi              #Salva o tamanho do bloco                   
    testb   %r8b, %r8b              # Testa o estado do bloco (0 = livre, 1 = ocupado)
    jnz     loopOcupado             # Se ocupado, pula para a lógica de blocos alocados
                                                                                
loopLivre:                                                                      
    cmpq    $0, %rsi                # Verifica se ainda há bytes no bloco       
    je      proximoBloco            # Se não, avança para o próximo bloco       
                                                                                
    movq    $charLivre, %rdi              # Define o caractere '-'                    
    call    imprimeCaractere        # Imprime o caractere                       
    incq    %rbx                    # Avança para o próximo byte                
    decq    %rsi                    # Decrementa o contador de bytes restantes  
    jmp     loopLivre               # Continua imprimindo '-'                   
                                                                                
loopOcupado:                                                                    
    cmpq    $0, %rsi                # Verifica se ainda há bytes no bloco       
    je      proximoBloco            # Se não, avança para o próximo bloco       
                                                                                
    movq    $charOcupado, %rdi              # Define o caractere '+'                    
    movq    $1, %rcx                # Marca que a heap não está vazia           
    call    imprimeCaractere        # Imprime o caractere                       
    incq    %rbx                    # Avança para o próximo byte                
    decq    %rsi                    # Decrementa o contador de bytes restantes  
    jmp     loopOcupado             # Continua imprimindo '+'                   
                                                                                
proximoBloco:                                                                   
    addq    %rax, %rbx              # Avança para o próximo bloco com base no tamanho
    jmp     loopMapa                # Recomeça o loop                           
                                                                                
verificaVazio:                                                                  
    cmpq    $0, %rcx                # Verifica se a heap está completamente vazia
    jne     fimImp                	# Se não está, termina a função             
                                                                                
    # Imprime "<vazio>"                                                         
    lea     vazio(%rip), %rsi                                                                                                                                                                                                                                                                                                   
    movq    $8, %rdx                # Tamanho da string "<vazio>"               
    movq    $1, %rax                # Syscall: write                            
    movq    $1, %rdi                # File descriptor: stdout                   
    syscall                                                                     
                                                                                
fimImp:                                                                            
    popq    %rbp                    # Restaura o ponteiro base                  
    ret
                             # Retorna       
# Função para imprimir um caractere                                             
imprimeCaractere:                                                               
    pushq   %rbp                                                                
    movq    %rsp, %rbp                                                          
                                                                                
    movq    $1, %rax                # Syscall: write                            
    movq    $1, %rdi                # File descriptor: stdout                   
    lea     caractere(%rip), %rsi   # Endereço do caractere                     
    movq    $1, %rdx                # Tamanho: 1 byte                           
    syscall                                                                     
                                                                                
    popq    %rbp                                                                
    ret                                                                         
                                                                                
# Função para imprimir o cabeçalho ('#')                                        
imprimeCabecalho:                                                               
    pushq   %rbp                                                                
    movq    %rsp, %rbp                                                          
                                                                                
    movq    $16, %rcx               # Tamanho do cabeçalho (16 bytes)           
cabecalhoLoop:                                                                  
    cmpq    $0, %rcx                # Verifica se todos os bytes foram processados
    je      fimCabecalho            # Se sim, sai do loop                       
                                                                                
    movq    $charCabecalho, %rdi              # Caractere '#'                             
    call    imprimeCaractere        # Imprime o caractere                       
    decq    %rcx                    # Decrementa o contador                     
    jmp     cabecalhoLoop           # Repete para o próximo byte                
                                                                                
fimCabecalho:                                                                   
    popq    %rbp                                                                
    ret                                                                                                                           
