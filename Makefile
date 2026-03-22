# Makefile for pidiv

AS = as
LD = ld
CC = gcc

ASM_TARGETS = divide dividePi
C_TARGETS = piCalc
TARGETS = $(ASM_TARGETS) $(C_TARGETS)

.PHONY: all clean run verify

all: $(TARGETS)

divide: divide.o
	$(LD) $< -o $@

divide.o: divide.s
	$(AS) $< -o $@

dividePi: dividePi.o
	$(LD) $< -o $@

dividePi.o: dividePi.s
	$(AS) $< -o $@

piCalc: piCalc.c
	$(CC) -O2 -o $@ $<

run: $(TARGETS)
	@./divide
	@./dividePi
	@./piCalc

verify: $(TARGETS)
	@echo "=== divide (100 / 7) ==="
	@echo -n "asm:   "; ./divide
	@echo -n "check: "; python3 -c "print(f'{100//7} R {100%7}')"
	@echo ""
	@echo "=== dividePi (pi / 7) ==="
	@echo -n "asm:   "; ./dividePi
	@echo -n "check: "; python3 -c "import math; print(f'{math.pi/7:.9f}')"
	@echo ""
	@echo "=== piCalc (100 digits) ==="
	@echo -n "calc:  "; ./piCalc
	@echo -n "check: "; echo "3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"

clean:
	rm -f *.o $(TARGETS)
