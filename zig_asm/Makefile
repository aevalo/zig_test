all: c_asm

c_asm: make_build casm.o my_strlen.o add.o
	gcc build/casm.o build/add.o build/my_strlen.o -o c_asm

make_build:
	 if ! [ -d build ]; then mkdir build; fi

casm.o:
	gcc -c src/casm.c -o build/casm.o

add.o:
	nasm -f elf64 -o build/add.o src/add.asm

my_strlen.o:
	nasm -f elf64 -o build/my_strlen.o src/my_strlen.asm

clean:
	if [ -d build ]; then rm -r build; fi
	if [ -f c_asm ]; then rm c_asm; fi
