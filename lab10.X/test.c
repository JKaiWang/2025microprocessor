#include <xc.h>
#include <pic18f4520.h>
#include "test_uart.h"


#define _XTAL_FREQ 4000000

volatile unsigned char counter= 0;
volatile unsigned char btn_pressed = 0;
volatile char number[] = {'0' , '1' , '2' , '3' ,'4' , '5' , '6' , '7' , '8' , '9' } ;
//void UART_init(void){//    TRISCbits.TRISC7 =1;
//    TRISCbits.TRISC6 = 1;
//    
//    SPBRG = 51;
//    TXSTAbits.BRGH = 0;
//    BAUDCONbits.BRG16 = 0;
//    
//    RCSTAbits.SPEN = 1;
//    TXSTAbits.TXEN = 1;
//}

void UART_write(char c){
    while(!TXSTAbits.TRMT);
    TXREG = c;
}

unsigned char prev_len = 1;   // ??? '0' ? 1 ??

void UART_write_number(unsigned char n){
    if(n >= 10){
        UART_write('0' + n/10);
        UART_write('0' + n%10);
    } else {
        UART_write('0' + n);
    }
}


void LED_update(unsigned char val) {
    LATDbits.LATD4 = (val >> 0) & 1;
    LATDbits.LATD5 = (val >> 1) & 1;
    LATDbits.LATD6 = (val >> 2) & 1;
    LATDbits.LATD7 = (val >> 3) & 1;
}

void __interrupt(high_priority) high_isr(void){
    if(INTCONbits.INT0IF){
        INTCONbits.INT0IF =0;
        
        __delay_ms(20);
        
        if(PORTBbits.RB0 == 0){
            btn_pressed = 1;
        }
    }
}

void INT0_init(void){
    TRISBbits.RB0 =1;
    INTCON2bits.RBPU =0;
    INTCON2bits.INTEDG0 = 0;
    
    INTCONbits.INT0IF = 0;
    INTCONbits.INT0IE = 1; 
}
void main(void) {
    
    OSCCONbits.IRCF = 0b110;
    TRISD =0x00;
    LATD = 0x00;
    
    RCONbits.IPEN = 1;
    INT0_init();
    
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1;
    
    test_uart_init();
    
    UART_write('0');
    UART_write('\b');
    LED_update(0);
    
    while(1){
        if(btn_pressed){
            btn_pressed=0;
            counter+=1;
            for(unsigned char i = 0; i < prev_len; i++){
                UART_write('\b');
            }
            UART_write('\r');           // clear line or go back to start
            UART_write_number(counter);
            prev_len = (counter >= 10) ? 2 : 1;
            
            unsigned char led_counter = counter % 16;
            LED_update(led_counter);
          
        }
  
    }
}
