#include <stdio.h>
#include <stdlib.h>

#include "add.h"
#include "hello.h"
#include "my_strlen.h"

int main(int argc, char *argv[]) {
    fprintf(stdout, "3 + 7 = %d\n", add(3, 7));

    hello_world();

    if (argc != 2) {
        fprintf(stderr, "Error: this program must have 1 command line argument\n");
        return EXIT_FAILURE;
    }

    fprintf(stdout, "The length of \"%s\" is %d\n", argv[1], my_strlen(argv[1]));

    return 0;
}
