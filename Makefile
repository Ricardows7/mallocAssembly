# Nome do executável final
EXECUTAVEL = exemplo

# Arquivos
C_SOURCE = exemplo.c
ASM_SOURCE = trab_updated.asm
ASM_OBJECT = trab.o

# Compiladores
CC = gcc
AS = as

# Flags
CFLAGS = -Wall -Wextra -g
ASFLAGS = --64

# Alvo padrão
all: $(EXECUTAVEL)

# Compilar o executável
$(EXECUTAVEL): $(C_SOURCE) $(ASM_OBJECT)
	$(CC) $(CFLAGS) -o $@ $^

# Compilar o Assembly para objeto
$(ASM_OBJECT): $(ASM_SOURCE)
	$(AS) $(ASFLAGS) -o $@ $<

# Limpar os arquivos gerados
clean:
	rm -f $(EXECUTAVEL) $(ASM_OBJECT)
