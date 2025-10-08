#INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF 
    org 0x00    ;PC = 0x10 
    MOVLW 0xFE ; 11111110
    MOVWF 0x00
    MOVLW 0xFC ; 00000100
    MOVWF 0x01
    MOVLW 0x00 
    MOVWF 0x03 ; sign bit
    MOVLW 0x01
    check0:
	BTFSC 0x00 , 3
	GOTO negative_to_positive0
	GOTO check1
    check1:
	BTFSC 0x01, 3
	GOTO negative_to_positive1
	GOTO mul
	
    
    negative_to_positive0:
	MOVLW 0x00
	MOVWF 0x04
	
	MOVF 0x00 ,W
	SUBWF 0x04
	MOVF 0x04, W
	MOVWF 0x00
	MOVF 0x03, W 
	XORLW 0x01
	MOVWF 0x03
	GOTO check1 
	
    negative_to_positive1:
	MOVLW 0x00
	MOVWF 0x05
	MOVF 0x01 ,W
	SUBWF 0x05
	MOVF 0x05, W
	MOVWF 0x01
	MOVF 0x03,W
	XORLW 0x01
	MOVWF 0x03
	GOTO mul
    mul:
	BTFSC 0x01 ,0
	GOTO zero
    mul1:
	BTFSC 0x01 , 1
	GOTO one
	RLCF 0x00
    mul2:
	BTFSC 0x01, 2
	GOTO two
	GOTO check_negative
    zero:
	MOVF 0x00 , W
	ADDWF 0x02
	
	GOTO mul1
    one: 
	RLCF 0x00
	MOVF 0x00 , W
	ADDWF 0x02
	
	GOTO mul2
    two:
	RLCF 0x00
	MOVF 0x00 ,W 
	ADDWF 0x02
	
	GOTO check_negative
    check_negative: 
	MOVLW 0x00
	CPFSEQ 0x03
	GOTO positive_to_negative
	GOTO final_program
	
	
    positive_to_negative:
	MOVF 0x02,W
	SUBWF 0x06
	MOVF 0x06,W
	MOVWF 0x02
    final_program:
    NOP
    end
	
	
	
	


