#include<xc.h>
#include<pic18f4520.h>


#define _XTAL_FREQ 1000000

#pragma config OSC = INTIO67
#pragma config WDT = OFF
#pragma config PBADEN = OFF
#pragma config LVP = OFF

void ADC_init(){
    ADCON0 = 0b00000001;
    ADCON1 = 0b00001110;
    ADCON2 = 0b10101010;
}

unsigned char ADC_read(){
    ADCON0bits.GO = 1;
    while(ADCON0bits.GO);
    return ADRESH;
}

void main(){
    TRISD = 0x00;
    PORTD = 0x00;
    
    ADC_init();
    
    unsigned char prev = ADC_read();
    unsigned char curr;
    
    unsigned char even_num = 0;
    unsigned char odd_num = 1;
    
    while(1){
        curr = ADC_read();
        if(curr > prev){
            PORTD = (even_num<<4);
            even_num = (even_num+2)%16;
        }
        else if(curr < prev){
            PORTD = (odd_num << 4);
            odd_num = (odd_num +2) %16;
        }
        
        prev = curr;
        __delay_ms(80);
    }
    
}