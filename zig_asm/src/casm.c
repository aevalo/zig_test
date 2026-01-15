#include <stdio.h>
#include <stdlib.h>

#include "add.h"
#include "my_strlen.h"

int main(int argc, char *argv[]) {
    printf("3 + 7 = %d\n", add(3, 7));

    if (argc != 2) {
        fprintf(stderr, "Error: this program must have 1 command line argument\n");
        return EXIT_FAILURE;
    }

    printf("The length of \"%s\" is %d\n", argv[1], my_strlen(argv[1]));

    return 0;
}
