
#include <xc.h>
extern long mul_extended(int n , int m);
void main(void) {
    volatile long ans = mul_extended(79 , 997);
    while(1);
    return;
}
