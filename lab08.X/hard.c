#include <xc.h>
#include <pic18f4520.h>
#define _XTAL_FREQ 1000000

#pragma config OSC = INTIO67    // Oscillator Selection bits
#pragma config WDT = OFF        // Watchdog Timer Enable bit 
#pragma config PWRT = OFF       // Power-up Enable bit
#pragma config BOREN = ON       // Brown-out Reset Enable bit
#pragma config PBADEN = OFF     // Watchdog Timer Enable bit 
#pragma config LVP = OFF        // Low Voltage (single -supply) In-Circute Serial Pragramming Enable bit
#pragma config CPD = OFF        // Data EEPROM?Memory Code Protection bit (Data EEPROM code protection off)

// Pulse Width: 500 ~ 2400 µs (-90° ~ 90°, 1450 µs = 0°)
int state=0;
int Counterclockwise = 1;
volatile unsigned int tick_count = 0;

void Timer1_Init(void) {
    T1CONbits.TMR1CS = 0;    // ?????? (Fosc/4)
    T1CONbits.T1CKPS = 0b01; // ??? 1:2
    TMR1H = 0xFF;             // ? ?? = 0xFFF0
    TMR1L = 0xF0;
    PIR1bits.TMR1IF = 0;      // ??????
    PIE1bits.TMR1IE = 1;      // ?? Timer1 ??
    T1CONbits.TMR1ON = 1;     // ?? TMR1
}


void delay_ms_timer1(unsigned int ms) {
    unsigned int start = tick_count;
    while ((tick_count - start) < ms) {
        // ?? ms ????
    }
}


void set_servo_angle(int angle) {
    /**
     * Duty cycle
     * = (CCPR1L:CCP1CON<5:4>) * Tosc * (TMR2 prescaler)
     * = (0x0b*4 + 0b01) * 8µs * 4
     * = 0.00144s ~= 1450µs
     */
    int cur_angle = (CCPR1L << 2) + CCP1CONbits.DC1B;
    int target_angle = 0;
    if(angle == -90){
        target_angle = 500 / 8 / 4;
    }else if(angle == 0){
        target_angle = 1450 / 8 / 4;
    }else if(angle == 90){
        target_angle = 2400 / 8 / 4;
    }else if(angle == 45){
        target_angle = (2400+1450) / 8 / 4 / 2;
    }else if(angle == -45){
        target_angle = (500+1450) / 8 / 4 / 2;
    }
    while(cur_angle != target_angle){
        if(cur_angle < target_angle) cur_angle++;
        else cur_angle--;
        
        if(state == 0){
            delay_ms_timer1(10);
            return;
        }
        
        CCPR1L = (cur_angle >> 2);
        CCP1CONbits.DC1B = (cur_angle & 0b11);
        
        CCPR2L = (cur_angle >> 2);
        CCP2CONbits.DC2B = (cur_angle & 0b11);
        delay_ms_timer1(22);
    }
//    __delay_ms(100);
}

void __interrupt(high_priority) H_ISR(){
    
    
   if (PIR1bits.TMR1IF) {
        PIR1bits.TMR1IF = 0;  // ????
        TMR1H = 0xFF;         // ????
        TMR1L = 0xF0;
        tick_count++;          // ? 1ms ? tick_count +1
    }
    
    if (INTCONbits.INT0IF) {
        state = !state;       // ????
        __delay_ms(100);      // ????
        INTCONbits.INT0IF = 0;
    }
    
    // Clear interrupt flag
    INTCONbits.INT0IF=0;
}

void main(void)
{  
    
    OSCCONbits.IRCF = 0b001;
    
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1; // ??????
    INTCONbits.INT0IE = 1;

    Timer1_Init(); // ???Timer1
    // Timer2 -> On, prescaler -> 4
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;

    // Internal Oscillator Frequency, Fosc = 125 kHz, Tosc = 8 µs
    //OSCCONbits.IRCF = 0b001;
    
    // PWM mode, P1A, P1C active-high; P1B, P1D active-high
    CCP1CONbits.CCP1M = 0b1100;
    
        // CCP2 -> PWM ????? LED
    CCP2CONbits.CCP2M = 0b1100; // PWM mode
    TRISCbits.TRISC1 = 0;       // RC1 = CCP2 ?? (? LED)
    
    // RB0 -> Input
    TRISB = 1;
    // CCP1/RC2 -> Output
    TRISC = 0;
    LATC = 0;
    
    // Set up PR2, CCP to decide PWM period and Duty Cycle
    /** 
     * PWM period
     * = (PR2 + 1) * 4 * Tosc * (TMR2 prescaler)
     * = (0x9b + 1) * 4 * 8µs * 4
     * = 0.019968s ~= 20ms
     */
    PR2 = 0x9b;
    
    // set -90 degree
    CCPR1L = 3;
    CCP1CONbits.DC1B = 3;
    
    //set_servo_angle(-90);
    
    while(!state);
    while(1){
        if(state == 1){
            if(Counterclockwise == 1){
                set_servo_angle(90);
                Counterclockwise = 0;
            }else{
                set_servo_angle(-90);
                Counterclockwise = 1;
            }
        }    
    }
    return;
}
