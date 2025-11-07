LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    ;first - second = answer
    first_high EQU 0x10
    first_low	EQU 0x11
    second_high	EQU 0x20
    second_low	EQU 0x21
    answer_high	EQU 0x00
    answer_low	EQU 0x01
    MOVLW 0x20
    MOVWF first_high
    MOVLW 0x30
    MOVWF first_low
    MOVLW 0x09
    MOVWF second_high
    MOVLW 0x25
    MOVWF second_low
    main:
	MOVF second_low ,W
	CPFSLT first_low ;  W > f , skip next line
	GOTO keep_going
	GOTO borrow
    keep_going:
	MOVFF first_low , answer_low
	MOVF second_low , W
	SUBWF answer_low 
	GOTO high_sub
    borrow:
	DECF first_high
	MOVLW 0xFF
	MOVWF answer_low
	MOVF second_low , W
	SUBWF answer_low
	INCF answer_low
	MOVF first_low ,W
	ADDWF answer_low , W
	MOVWF answer_low
	GOTO high_sub
    high_sub:
	MOVFF first_high , answer_high
	MOVF second_high , W
	SUBWF answer_high
    NOP
	end
    
	
	


