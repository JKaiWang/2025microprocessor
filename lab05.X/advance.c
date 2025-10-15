#include<xc.h>
#pragma config WDT = OFF
extern unsigned int count_primes(unsigned int n , unsigned int m);

void main(void){
    volatile unsigned int ans = count_primes(1, 10000);
    while(1);
    return ;
}