LIST p=18f4520
    #include <pic18f4520.inc>
    CONFIG OSC = INTIO67 
    CONFIG WDT = OFF    
    CONFIG LVP = OFF     
    L1	EQU 0x14
    L2	EQU 0x15
    MODE    EQU 0x20
DELAY macro n1 , n2
    local LOOP1
    local LOOP2
    
    MOVLW n2
    MOVWF L2
    LOOP2:
	MOVLW n1 
	MOVWF L1
	LOOP1:
	    BTFSC PORTB , 0
	    BRA CON
	    GOTO ADD 
	    CON:
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    DECFSZ L1 , 1
	    BRA LOOP1
	    
	DECFSZ L2 ,1
	BRA LOOP2
	
endm






