#include <stdlib.h>

double drand48(void) {
    return rand() / (RAND_MAX + 1.0);
}

void srand48(long int seedval) {
    srand(seedval);
}
