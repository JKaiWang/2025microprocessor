LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00

    
    
    MOVLW 0x0F
    MOVWF 0x10
    MOVLW 0x01
    MOVWF 0x11
    MOVLW 0x0E
    MOVWF 0x

