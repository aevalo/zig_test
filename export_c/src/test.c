#include "mathtest.h"
#include <stdio.h>
#include <stdint.h>

int main(int argc, char **argv) {
    int32_t result = add(42, 69);
    printf("%d\n", result);
    return 0;
}
