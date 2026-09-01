#include "mathtest.h"
#include <stdio.h>
#include <stdint.h>

int main(int argc, char **argv) {
    sayHello(420);
    int32_t result = add(42, 69);
    printf("add(42, 69) = %d\n", result);
    return 0;
}
