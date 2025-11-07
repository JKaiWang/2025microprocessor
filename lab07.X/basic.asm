LIST p=18f4520
    #include "pic18f4520.inc"
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    CONFIG LVP = OFF
    L1 EQU 0x14
    L2 EQU 0x15
    mode EQU 0x20
    org 0x00
    
DELAY macro num1, num2 
    local LOOP1 
    local LOOP2
    MOVLW num2
    MOVWF L2
    LOOP2:
	MOVLW num1
	MOVWF L1
    LOOP1:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ L1, 1
	BRA LOOP1
	DECFSZ L2, 1
	BRA LOOP2
endm
	

goto Initial			; ISR
ISR:	
  
    ; Interrupt LATD 4 5 6 7
    org 0x08
    BTG mode ,0
    BCF INTCON, 1 ; INT0IF = 1
    RETFIE                

    
Initial:
    MOVLW 0x0F
    MOVWF ADCON1		
    CLRF TRISD
    CLRF LATD
    BSF TRISB,  0
    BCF RCON, 7 ; IPEN = bit7
    BCF INTCON, 1 ; INT0IF =1		; ??Interrupt flag bit??
    BSF INTCON, 7 ; GIE = 7		; ?Global interrupt enable bit??
    BSF INTCON, 4 ; INT0IE =4	; ?interrupt0 enable bit ?? (INT0?RB0 pin?????)
    
main:
state_1:
    CLRF LATD
    DELAY 111 , 125
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD ,7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD 
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 7
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 5
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD ,5
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 5
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 5
    BSF LATD , 6
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 4
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 4
    BSF LATD ,7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 4
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 4
    BSF LATD , 6
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 4
    BSF LATD , 5
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 4
    BSF LATD , 5
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 4
    BSF LATD , 5
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSC mode , 0
    GOTO state_2
    BSF LATD , 4
    BSF LATD , 5
    BSF LATD , 6
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    ;GOTO state_1
state_2:
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    BSF LATD , 5
    BSF LATD , 6
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    BSF LATD , 5
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    BSF LATD , 5
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    BSF LATD , 5
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    BSF LATD , 5
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    BSF LATD , 6
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    BSF LATD ,7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 4
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 5
    BSF LATD , 6
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 5
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD ,5
    BSF LATD , 7
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 5
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 7
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD , 6
    DELAY 111 , 125
    CLRF LATD
    
    BTFSS mode , 0
    GOTO state_1
    BSF LATD ,7
    DELAY 111 , 125
    CLRF LATD
    
    
    GOTO state_2
end
