LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    
    
    ; utake the floor of the square root
    ; input 16 bit 
    ; output 8 bit
    input_high  EQU 0x10
    input_low	EQU 0x11
    output  EQU 0x00
    
    temp1   EQU 0x21
    
    m1_low   EQU 0x31 ; temp1*temp1 low
    m1_high  EQU 0x30 ; temp1*temp1 high
    
  
    MOVLW 0xFF
    MOVWF input_high
    MOVLW 0xFF
    MOVWF input_low
    
    MOVLW 0xF6
    MOVWF temp1
    
    loop:
	MOVFF input_high , 0x50
	MOVFF input_low , 0x51
	
	INCF temp1
	
	
	MOVF temp1 , W
	MULWF temp1
	
	
    cont:
	MOVFF PRODL , m1_low
	MOVFF PRODH , m1_high
	GOTO determine
    biggest:
	MOVFF temp1 , output
	GOTO end_program
    determine:
	CALL comparator
	MOVLW 0x00
	CPFSEQ output ; if output == 0 skip next line
	GOTO end_program
	GOTO loop
    comparator:
	input1high	EQU m1_high
	input1low	EQU m1_low
	input2high	EQU 0x50
	input2low	EQU 0x51
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
	DECF temp1
	MOVFF temp1 , output
	RETURN
	
    input2B:
	MOVLW 0xFF
	CPFSEQ temp1 ; if temp1 == 0xFF skip next line
	RETURN 
	GOTO biggest
    equal_case:
	MOVFF temp1 , output
	RETURN 
    not_equal:
	MOVF input1high , W
	CPFSLT input2high ; if input2high < input1high, skip next line
	GOTO input2B
	GOTO input1B
	
    end_program:
	NOP
	END
	
	
  


