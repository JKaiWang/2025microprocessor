#include <xc.h>
#include <pic18f4520.h>
#include "test_uart.h"

#define _XTAL_FREQ 4000000

volatile unsigned char current_out = 4; // mapping output 4~15
volatile unsigned char prev_out = 4 ; // last output
static unsigned char prev_len = 0 ; // last UART show number

static inline void UART_putc(char c){
    test_uart_write((unsigned char) c);
}

unsigned char UART_print_dec(unsigned int v){
    char buf[5];
    unsigned char len = 0;
    int i;
    
    if(v == 0){
        UART_putc('0');
        return 1;
    }
    while(v>0){
        buf[len++] = '0'+ (v%10);
        v/=10;
    }
    for(int i = len -1 ; i >= 0 ; i--){
        UART_putc(buf[i]);
    }
    return len ;
}

void UART_update_adc(unsigned int adc_value){
    unsigned char i;

    for(i=0 ; i<prev_len ; i++){
        UART_putc('\b');
    }
    for(i=0 ; i<prev_len ; i++){
        UART_putc(' ');
    }
    for(i=0 ; i<prev_len ; i++){
        UART_putc('\b');
    }
    prev_len = UART_print_dec(adc_value);
}

void LED_update(unsigned char val){
    LATDbits.LATD4 = (val>>0) &1;
    LATDbits.LATD5 = (val>>1) &1;
    LATDbits.LATD6 = (val>>2) &1;
    LATDbits.LATD7 = (val>>3) &1;   
}

unsigned int ADC_read_AN0(void){
    ADCON0bits.CHS = 0 ; // channel = AN 0
    __delay_us(10);
    ADCON0bits.GO = 1;
    while(ADCON0bits.GO);
    return(((unsigned int)ADRESH) << 8) | ADRESL ;
}
unsigned char map_adc_to_output(unsigned int adc){
    if(adc < 85) return 0x04;
    else if(adc >= 85 && adc < 170) return 0x05;
    else if(adc >= 170 && adc < 256) return 0x06;
    else if(adc >= 256 && adc < 341) return 0x07;
    else if(adc >= 341 && adc < 426) return 0x08;
    else if(adc >= 426 && adc < 512) return 0x09;
    else if(adc >= 512 && adc < 597) return 0x0A;
    else if(adc >= 597 && adc < 682) return 0x0B;
    else if(adc >= 682 && adc < 767) return 0x0C;
    else if(adc >= 767 && adc < 852) return 0x0D;
    else if(adc >= 852 && adc < 938) return 0x0E;
    else return 0x0F;
}

void ADC_init(void){
    TRISAbits.TRISA0 = 1;

    ADCON1 = 0x0E;

    ADCON2bits.ADFM = 1;
    ADCON2bits.ADCS = 0b010;
    ADCON2bits.ACQT = 0b010;

    ADCON0bits.CHS = 0;
    ADCON0bits.ADON = 1;
}

void main(void){
    OSCCONbits.IRCF = 0b110;

    TRISD = 0x00 ;
    LATD = 0x00 ; 

    test_uart_init();

    ADC_init();

    unsigned int adc_val = ADC_read_AN0();
    current_out = map_adc_to_output(adc_val);
    prev_out = current_out ;

    LED_update(current_out);
    UART_update_adc(adc_val);

    while(1){
        adc_val = ADC_read_AN0();
        current_out = map_adc_to_output(adc_val);

        if(current_out != prev_out){
            prev_out = current_out ; 

            LED_update(current_out);

            UART_update_adc(adc_val);
        }
        __delay_ms(10);
    }
}