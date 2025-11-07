LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    
    ;if input1 > input2 return 0x01 in 0x00 
    ;if input1 == input2 return 0x02 in 0x00 
    ;if input1 < input2 return 0xFF in 0x00
    input1high	EQU 0x10
    input1low	EQU 0x11
    input2high	EQU 0x20
    input2low	EQU 0x21
    MOVLW 0x21
    MOVWF 0x10
    MOVLW 0x22
    MOVWF 0x11
    MOVLW 0x22
    MOVWF 0x20
    MOVLW 0x22
    MOVWF 0x21
    high_equal:
	MOVF input1high , W
	CPFSEQ input2high 
	GOTO not_equal
	GOTO low_equal
    low_equal:
	MOVF input1low , W
	CPFSEQ input2low
	GOTO low_not_equal
	GOTO equal_case
    low_not_equal:
	MOVF input1low , W
	CPFSLT input2low ; if input2low < WREG skip next line
	GOTO input2B
	GOTO input1B 
    input1B:
	MOVLW 0x01
	MOVWF 0x00
	GOTO end_program
    input2B:
	MOVLW 0xFF
	MOVWF 0x00
	GOTO end_program
    equal_case:
	MOVLW 0x02
	MOVWF 0x00
	GOTO end_program
    not_equal:
	MOVF input1high , W
	CPFSLT input2high ; if input2high < input1high, skip next line
	GOTO input2B
	GOTO input1B
	
    end_program:
	NOP
	END
	
    


