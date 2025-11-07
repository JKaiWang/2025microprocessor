List p=18f4520
    #include<pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
input1_high EQU 0x00
input1_low  EQU 0x01
input2	EQU 0x10
answer_high  EQU 0x20
answer_mid   EQU 0x21
answer_low  EQU 0x22
MOVLW 0x10
MOVWF input1_high
	
MOVLW 0x15 
MOVWF input1_low
	
MOVLW 0x20 
MOVWF input2

_mul16x8:
    CLRF answer_high
    CLRF answer_mid
    CLRF answer_low

    MOVF input1_low , W
    MULWF input2
    MOVFF PRODL , answer_low
    MOVFF PRODH , answer_mid
    
    MOVF input1_high , W 
    MULWF input2
    MOVF PRODL , W
    ADDWF answer_mid,F
    MOVF PRODH,W
    ADDWFC answer_high , F
    
end

