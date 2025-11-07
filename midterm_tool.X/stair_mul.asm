LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00

    input   EQU 0x10
    output_low  EQU 0x01
    output_high	EQU 0x00
    carry   EQU 0x03
    MOVLW 0x07
    MOVWF input
    
    MOVLW 0x01
    MOVWF output_low
    CLRF output_high
    mul:
        CLRF carry
	MOVF output_low , W
	MULWF input
	MOVFF PRODL , output_low
	MOVLW output_high
	CPFSEQ PRODH
	GOTO add_high
	GOTO con
    add_high:
	
	MOVF PRODH , W
	ADDWF carry , W
	MOVWF carry
    con:
	MOVF output_high , W
	MULWF input
	MOVFF PRODL , output_high
	MOVF output_high , W
	ADDWF carry , W
	MOVWF output_high
	DECFSZ input 
	GOTO mul
	GOTO end_program
    end_program:
    NOP
    END

    


