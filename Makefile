# Makefile для divide.s

AS = as
LD = ld

TARGET = divide
SRC = divide.s
OBJ = divide.o

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) $(OBJ) -o $(TARGET)

$(OBJ): $(SRC)
	$(AS) $(SRC) -o $(OBJ)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)
