#include <xc.h>
#include <pic18f4520.h>
#include <stdio.h>

#pragma config OSC = INTIO67
#pragma config WDT = OFF
#pragma config PWRT = OFF
#pragma config BOREN = ON
#pragma config PBADEN = OFF
#pragma config LVP = OFF
#pragma config CPD = OFF     

#define _XTAL_FREQ 1000000

// ------- ???? 2025/11/20 --------
int date_digits[] = {2, 0, 2, 5, 1, 1, 2, 0};
#define DATE_LEN 8

int index = 0;
int last_value = 0;
int threshold = 10;   // ADC ?????

void display_binary(int num){
    PORTD = (num << 4);   // RD4~RD7 ?? 4-bit
}

void __interrupt(high_priority) H_ISR(){

    int value = ADRESH;   // ??? ? 8-bit ??

    // ----------- ?????????? -----------
    if(value - last_value > threshold || last_value - value > threshold)
    {
        // ?????? digit
        display_binary(date_digits[index]);
        index++;
        if(index >= DATE_LEN) index = 0;

        last_value = value;
    }

    // ?????
    PIR1bits.ADIF = 0;

    // ??? 2 Tad????
    __delay_ms(5);

    // ??? ADC
    ADCON0bits.GO = 1;
}

void main(void)
{
    // ??
    OSCCONbits.IRCF = 0b100; // 1MHz

    // AN0 ??
    TRISAbits.RA0 = 1;

    // LED?RD4~RD7 output
    TRISD = 0b00001111;

    // ---------- ADC ?? ----------
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG1 = 0;
    ADCON1bits.PCFG = 0b1110;   // AN0 analog

    ADCON0bits.CHS = 0b0000;    // AN0

    ADCON2bits.ADCS = 0b000;    // Fosc/2
    ADCON2bits.ACQT = 0b001;    // 2 Tad
    ADCON2bits.ADFM = 0;        // ???
    ADCON0bits.ADON = 1;

    // --------- ???? ----------
    PIE1bits.ADIE = 1;
    PIR1bits.ADIF = 0;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;

    // ---------- ??? ADC ----------
    ADCON0bits.GO = 1;

    while(1);
}
