all: c_asm

c_asm: make_build main.o add.o hello.o my_strlen.o
	gcc build/main.o build/add.o build/hello.o build/my_strlen.o -o build/c_asm

make_build:
	 if ! [ -d build ]; then mkdir build; fi

main.o:
	gcc --std=c99 -c src/main.c -o build/main.o

add.o:
	nasm -f elf64 -o build/add.o src/add.asm

hello.o:
	nasm -f elf64 -o build/hello.o src/hello.asm

my_strlen.o:
	nasm -f elf64 -o build/my_strlen.o src/my_strlen.asm

clean:
	if [ -d build ]; then rm -r build; fi
