.section .text
.global imprimeMapa

# Função principal que imprime o mapa da memória
imprimeMapa:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	inicioHeap, %rbx		# Carrega o início da heap
	movq	topoInicialHeap, %r10	# Carrega o topo inicial da heap

	movq	$0, %rcx				# Flag para indicar se a heap está completamente liberada

loopMapa:
	cmpq	%rbx, %r10				# Verifica se chegou ao topo da heap
	jge		verificaVazio			# Sai do loop se %rbx >= %r10

	# Imprime o cabeçalho do nó
	movq	%rbx, %rdi				# Endereço atual do bloco
	call	imprimeCabecalho		# Imprime os bytes do cabeçalho como '#'

	# Verifica o estado do bloco
	movq	(%rbx), %rax			# Carrega o tamanho do bloco (do cabeçalho)
	addq	$16, %rbx				# Move o ponteiro %rbx para a área de dados do bloco (16 bytes para cabeçalho)

	movq	(%rbx), %r8b			# Carrega o primeiro byte da área de dados
	testb	%r8b, %r8b				# Testa o estado do bloco (0 = livre, 1 = ocupado)
	jnz		blocoOcupado			# Se ocupado, pula para a lógica de blocos alocados

blocoLivre:
	movq	%rax, %rsi				# Copia o tamanho do bloco para %rsi
loopLivre:
	cmpq	$0, %rsi				# Verifica se ainda há bytes no bloco
	je		proximoBloco			# Se não, avança para o próximo bloco

	movq	$"-", %rdi				# Define o caractere '-'
	call	imprimeCaractere		# Imprime o caractere
	incq	%rbx					# Avança para o próximo byte
	decq	%rsi					# Decrementa o contador de bytes restantes
	jmp		loopLivre				# Continua imprimindo '-'

blocoOcupado:
	movq	%rax, %rsi				# Copia o tamanho do bloco para %rsi
loopOcupado:
	cmpq	$0, %rsi				# Verifica se ainda há bytes no bloco
	je		proximoBloco			# Se não, avança para o próximo bloco

	movq	$"+", %rdi				# Define o caractere '+'
	movq	$1, %rcx				# Marca que a heap não está vazia
	call	imprimeCaractere		# Imprime o caractere
	incq	%rbx					# Avança para o próximo byte
	decq	%rsi					# Decrementa o contador de bytes restantes
	jmp		loopOcupado				# Continua imprimindo '+'

proximoBloco:
	addq	%rax, %rbx				# Avança para o próximo bloco com base no tamanho
	jmp		loopMapa				# Recomeça o loop

verificaVazio:
	cmpq	$0, %rcx				# Verifica se a heap está completamente vazia
	jne		fim						# Se não está, termina a função

	# Imprime "<vazio>"
	lea		vazio(%rip), %rsi
	movq	$8, %rdx				# Tamanho da string "<vazio>"
	movq	$1, %rax				# Syscall: write
	movq	$1, %rdi				# File descriptor: stdout
	syscall

fim:
	popq	%rbp					# Restaura o ponteiro base
	ret								# Retorna

.section .data
vazio: .asciz "<vazio>"

# Função para imprimir um caractere
imprimeCaractere:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$1, %rax				# Syscall: write
	movq	$1, %rdi				# File descriptor: stdout
	lea		caractere(%rip), %rsi	# Endereço do caractere
	movq	$1, %rdx				# Tamanho: 1 byte
	syscall

	popq	%rbp
	ret

# Função para imprimir o cabeçalho ('#')
imprimeCabecalho:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	$16, %rcx				# Tamanho do cabeçalho (16 bytes)
cabecalhoLoop:
	cmpq	$0, %rcx				# Verifica se todos os bytes foram processados
	je		fimCabecalho			# Se sim, sai do loop

	movq	$'#', %rdi				# Caractere '#'
	call	imprimeCaractere		# Imprime o caractere
	decq	%rcx					# Decrementa o contador
	jmp		cabecalhoLoop			# Repete para o próximo byte

fimCabecalho:
	popq	%rbp
	ret

.section .data
caractere: .byte 0
