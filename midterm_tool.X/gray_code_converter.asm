LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    
    
    ; gray code :right shift original bit sequeunce MSB must zero , and XOR original bit sequence
    MOVLW 0xE9
    MOVWF 0x10 
    MOVFF 0x10 , 0x11
    RRNCF 0x11
    MOVF 0x11 , W
    ANDLW 0b01111111
    MOVWF 0x11
    MOVF 0x11 , W
    XORWF 0x10 , W
    MOVWF 0x00
    end


