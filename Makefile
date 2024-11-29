# Nome do executável
EXECUTAVEL = exemplo

# Arquivos
C_SOURCE = exemplo.c
ASM_SOURCE = trab.asm
ASM_OBJECT = trab.o

# Compiladores
CC = gcc
ASM = nasm

# Flags
CFLAGS = -Wall -g
ASMFLAGS = -f elf64

# Alvo padrão
all: $(EXECUTAVEL)

# Compilar o executável
$(EXECUTAVEL): $(C_SOURCE) $(ASM_OBJECT)
	$(CC) $(CFLAGS) -o $@ $^

# Compilar o Assembly para objeto
$(ASM_OBJECT): $(ASM_SOURCE)
	$(ASM) $(ASMFLAGS) -o $@ $<

# Limpar os arquivos gerados
clean:
	rm -f $(EXECUTAVEL) $(ASM_OBJECT)

