.section .note.GNU-stack, "", @progbits

.section .bss
	.lcomm topoInicialHeap, 8	#Topo da heap
    .lcomm inicioHeap, 8	#Base da heap

.extern brk

.section .data                                                                  
vazio: .asciz "<vazio>"  
caractere: .byte 0
charLivre: .byte '-'
charOcupado: .byte '+'
charCabecalho: .byte '#'
newline: .byte 0x0A

.section .text                                                                                                                                                                     
.global iniciaAlocador                                                          
.global finalizaAlocador                                                        
.global liberaMem                                                               
.global alocaMem                                                                
.global imprimeMapa

iniciaAlocador:
	#movq %rsp, %rax         # Copia %rsp para um registrador temporário
    #andq $~0xF, %rsp        # Alinha %rsp a 16 bytes

    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax             # Syscall brk para obter topo da heap
    xorq %rdi, %rdi            # Set %rdi = 0 para indicar topo corrente
    syscall

    movq %rax, [topoInicialHeap]      # Armazena o endereço inicial no topo da heap
    movq %rax, [inicioHeap]    # Armazena o endereço inicial no início da heap

	addq $16, %rax
	movq %rax, [topoInicialHeap]
	movq %rax, %rdi
	movq $12, %rax
	syscall

	cmpq %rdi, %rax
	jne erro_brk

	movq inicioHeap, %rdx
	movq $1, (%rdx)
	movq $16, 8(%rdx)

    popq %rbp
    ret
erro_brk:
	int3

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
	movq %rcx, %r13                                                             
	addq $16, %r13
    movq $-1, %rsi               # Endereço do bloco best fit
    movq $-1, %rbx               # Menor tamanho de bloco

loop:
    cmpq $0, (%rdx)              # Verifica se o bloco está livre
    jne proximo_bloco            # Se ocupado, vai para o próximo bloco

    # Verifica se o bloco livre é grande o suficiente
    movq 8(%rdx), %rax           # Carrega o tamanho do bloco
    cmpq %r13, %rax
    jl proximo_bloco             # Se o bloco é menor que o solicitado, vai para o próximo

    # Se é um bloco adequado, verifica se é o menor bloco até agora (best fit)
    cmpq $-1, %rbx 			# Compara com o menor bloco encontrado até agora
    jne verifica            # Se for maior ou igual ao bloco encontrado, ignora
menor:
    movq %rax, %rbx              # Atualiza o tamanho do menor bloco encontrado
    movq %rdx, %rsi              # Atualiza o endereço do bloco best fit
	jmp proximo_bloco
verifica:
	cmpq %rbx, %rax
	jge proximo_bloco
	jmp menor
proximo_bloco:
    addq 8(%rdx), %rdx           # Avança para o próximo bloco
    #addq $16, %rdx               # Inclui espaço de controle
    cmpq %rdx, [topoInicialHeap]        # Verifica se chegou ao final da lista
    jg loop                      # Continua o loop se não for o fim

    # Verifica se encontramos um bloco livre adequado (best fit)
    cmpq $-1, %rsi               # Se %rsi ainda for -1, não encontrou bloco adequado
    jne achou_bloco              # Se encontrou, pula para achou_bloco

    # Se não encontrou um bloco livre, calcula o novo espaço em múltiplos de 4096 bytes
    movq %r13, %rax              # Move o tamanho solicitado para %rax
    addq $4095, %rax             # Arredonda para o próximo múltiplo de 4096
    andq $-4096, %rax            # Zera os últimos 12 bits para obter múltiplo de 4096
	movq %rax, %r12

    # Chama syscall brk para alocar o novo espaço arredondado
    movq $12, %rax
    movq [topoInicialHeap], %rdi
    addq %r12, %rdi              # Incrementa o topo da heap com o espaço necessário
    syscall

	movq [topoInicialHeap], %rsi
    movq %rax, [topoInicialHeap]        # Atualiza o topo da heap

    # Configura o novo bloco alocado
    #movq %rdx, %rsi              # Ponteiro do novo bloco
    movq $1, (%rsi)              # Define o bloco como ocupado
    movq %r12, 8(%rsi)           # Armazena o tamanho solicitado

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
                                                                                
    movq    inicioHeap, %r14        # Carrega o início da heap                  
    movq    topoInicialHeap, %r10   # Carrega o topo inicial da heap            
                                                                                
    movq    $0, %r12  
    movq 	$0, %r13  				# Flag para indicar se a heap está completamente liberada                                                                          
loopMapa:                                                                       
    cmpq    %r10, %r14              # Verifica se chegou ao topo da heap        
    jge     verificaVazio           # Sai do loop se %rbx >= %r10               
                                                                                
    # Imprime o cabeçalho do nó                                                 
    movq    %r14, %rdi              # Endereço atual do bloco                   
    call    imprimeCabecalho        # Imprime os bytes do cabeçalho como '#'    
                                                                                
    # Verifica o estado do bloco                                                
    movq    8(%r14), %rax           # Carrega o tamanho do bloco (do cabeçalho)
	subq 	$16, %rax 
    movb    (%r14), %r8b            # Carrega o primeiro byte da área de dados  
    addq    $16, %r14               # Move o ponteiro %rbx para a área de dados do bloco (16 bytes para cabeçalho)
   
	movq 	%rax, %r15				#Salva o tamanho do bloco
                  
	movq 	%rax, %rsi 
    testb   %r8b, %r8b              # Testa o estado do bloco (0 = livre, 1 = ocupado)
    jnz     loopOcupado             # Se ocupado, pula para a lógica de blocos alocados
                                                                                
loopLivre:                                                                      
    cmpq    $0, %r15                # Verifica se ainda há bytes no bloco       
    je      proximoBloco            # Se não, avança para o próximo bloco       
                                                                                
    movq    $charLivre, %rdi              # Define o caractere '-'                    
    call    imprimeCaractere        # Imprime o caractere                       
    incq    %r14                    # Avança para o próximo byte                
    decq    %r15                    # Decrementa o contador de bytes restantes  
    jmp     loopLivre               # Continua imprimindo '-'                   
                                                                                
loopOcupado:                                                                    
    cmpq    $0, %r15                # Verifica se ainda há bytes no bloco       
    je      proximoBloco            # Se não, avança para o próximo bloco       
                                                                                
    movq    $charOcupado, %rdi              # Define o caractere '+'                               
    call    imprimeCaractere        # Imprime o caractere                       
    incq    %r14                    # Avança para o próximo byte                
    decq    %r15                    # Decrementa o contador de bytes restantes  
    jmp     loopOcupado             # Continua imprimindo '+'                   
                                                                                
proximoBloco:                                                                   
    addq    %r15, %r14              # Avança para o próximo bloco com base no tamanho
    jmp     loopMapa                # Recomeça o loop                           
                                                                                
verificaVazio:                                                                  
    cmpq    $0, %r13                # Verifica se a heap está completamente vazia
    jne     fimImp                	# Se não está, termina a função             
                                                                                
    # Imprime "<vazio>"                                                         
    lea     vazio(%rip), %rsi                                                                                                                                                                                                                                                                                                   
    movq    $8, %rdx                # Tamanho da string "<vazio>"               
    movq    $1, %rax                # Syscall: write                            
    movq    $1, %rdi                # File descriptor: stdout                   
    syscall                                                                     
                                                                                
fimImp:
	movq 	$1, %rax
	movq 	$1, %rdi
	lea 	newline(%rip), %rsi
	movq 	$1, %rdx
	syscall
                                                                            
    popq    %rbp                    # Restaura o ponteiro base                  
    ret
                             # Retorna       
# Função para imprimir um caractere                                             
imprimeCaractere:                                                               
    pushq   %rbp                                                                
    movq    %rsp, %rbp                                                          
                                                                                
    movq    $1, %rax                # Syscall: write                                         
    movq 	%rdi, %rsi			    # Endereço do caractere                     
	movq    $1, %rdi                # File descriptor: stdout      
    movq    $1, %rdx                # Tamanho: 1 byte                           
    syscall                                                                     
                                                                                
    popq    %rbp                                                                
    ret                                                                         
                                                                                
# Função para imprimir o cabeçalho ('#')                                        
imprimeCabecalho:                                                               
    pushq   %rbp                                                                
    movq    %rsp, %rbp                                                          
                                                                                
    movq    $16, %r12               # Tamanho do cabeçalho (16 bytes)           
cabecalhoLoop:                                                                  
    cmpq    $0, %r12                # Verifica se todos os bytes foram processados
    je      fimCabecalho            # Se sim, sai do loop                       
                                                                                
    movq    $charCabecalho, %rdi              # Caractere '#'                             
    call    imprimeCaractere        # Imprime o caractere                       
    decq    %r12                    # Decrementa o contador
	movq 	$1, %r13                     
    jmp     cabecalhoLoop           # Repete para o próximo byte                
                                                                                
fimCabecalho:                                                                   
    popq    %rbp                                                                
    ret                                                                                                                           
