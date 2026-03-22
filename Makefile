# Makefile for pidiv

AS = as
LD = ld

TARGETS = divide dividePi

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

run: $(TARGETS)
	@./divide
	@./dividePi

verify: $(TARGETS)
	@echo "=== dividePi (pi / 7) ==="
	@echo -n "asm:   "; ./dividePi
	@echo -n "check: "; python3 -c "import math; print(f'{math.pi/7:.9f}')"

clean:
	rm -f *.o $(TARGETS)
