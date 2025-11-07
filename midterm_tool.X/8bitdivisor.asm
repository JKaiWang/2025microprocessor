LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    
    dividend   EQU 0x10
    divisor EQU 0x20
    quotient	EQU 0x30
    remainder	EQU 0x40
    
    
    MOVLW 0x0F
    MOVWF dividend
    MOVLW 0x0F
    MOVWF divisor
    CLRF quotient
    CLRF remainder
    
    MOVFF dividend , remainder
    
    main:
	MOVF remainder , W
	CPFSGT divisor ; if divisor> remainder skip next line
	GOTO keep_going
	GOTO end_program
    keep_going:
	MOVF divisor , W
	SUBWF remainder
	INCF quotient
	GOTO main
    end_program:
	NOP
	end


