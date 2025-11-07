LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    

   ; input1 must bigger then input2
    input1high	EQU 0x10
    input1low	EQU 0x11
    input2high	EQU 0x20
    input2low	EQU 0x21
    MOVLW 0x04
    MOVWF 0x60 ; copy one to 0x60
    MOVWF 0x10
    MOVLW 0x00
    MOVWF 0x61 ; copy one to 0x61
    MOVWF 0x11
    
    MOVLW 0x02
    MOVWF 0x70 ;copy one to 0x70
    MOVWF 0x20
    MOVLW 0x00
    MOVWF 0x71 ; copy one to 0x71
    MOVWF 0x21
    Ghigh  EQU 0x50
    Glow    EQU 0x51
    
    GOTO loop
    loop_init:
	MOVFF 0x20 , 0x10
	MOVFF 0x21 , 0x11
	MOVFF 0x40 , 0x20 
	MOVFF 0x41 , 0x21
	
    loop:
	CALL divisor
	MOVLW 0x00
	CPFSEQ 0x40
	GOTO loop_init
	GOTO check_low
    check_low:
	MOVLW 0x00
	CPFSEQ 0x41
	GOTO loop_init
	GOTO LCM
;================================================================================
;			16 bit / 16 bit divisor
;================================================================================
    divisor:
    Divide_high EQU 0x10
    Divide_low	EQU 0x11
    Divisor_high    EQU 0x20
    Divisor_low	EQU 0x21
    Quotient_high   EQU 0x30
    Quotient_low    EQU 0x31
    Remainder_high  EQU 0x40
    Remainder_low   EQU 0x41
    ;SUBWF  use f - wreg
division:
    CLRF    Quotient_high      ; Quotient high
    CLRF    Quotient_low      ; Quotient low

    MOVFF   Divide_high, Remainder_high  ; Remainder high = Dividend high
    MOVFF   Divide_low, Remainder_low   ; Remainder low  = Dividend low

div_loop:
    
    ; check remainder < divisor ?
    MOVF    Divisor_low, W
    SUBWF   Remainder_low, W
    MOVWF   0x007           ; store temporarily
    MOVF    Divisor_high, W
    SUBWFB  Remainder_high, W
    BTFSS   STATUS, 0       ; if C=0?means that remainder < divisor
    GOTO    div_done

    
    ; remainder = remainder - divisor
    MOVF    Divisor_low, W
    SUBWF   Remainder_low, F
    MOVF    Divisor_high, W
    SUBWFB  Remainder_high, F

    
    ; quotient++
    INCF    Quotient_low, F
    BTFSC   STATUS, 2
    INCF    Quotient_high, F

    GOTO    div_loop

div_done:
    RETURN
;================================================================================
;			16 bit / 16 bit divisor
;================================================================================	
	
LCM:
    MOVFF 0x20 , Ghigh
    MOVFF 0x21 , Glow
    
    MOVFF 0x60 , 0x10
    MOVFF 0x61 , 0x11
    MOVFF 0x50 , 0x20
    MOVFF 0x51 , 0x21
    
    CALL divisor
    ; do 0x70|0x71 * 0x30|0x31 muliply
    ; answer will be put into 0x00 0x01 0x02 0x03
    MOVF 0x71 ,W
    MULWF 0x31
    MOVFF PRODL , 0x03
    MOVFF PRODH , 0x02
    MOVF 0x71 , W
    MULWF 0x30
    MOVF PRODL , W
    ADDWF 0x02 ,W
    MOVWF 0x02
    MOVFF PRODH , 0x01
    
    MOVF 0x31 , W
    MULWF 0x70
    MOVF PRODL , W
    ADDWF 0x02 , W
    MOVWF 0x02
    MOVF PRODH , W
    ADDWF 0x01 ,W
    MOVLW 0x01
    
    MOVF 0x70 , W
    MULWF 0x30
    MOVF PRODL ,W
    ADDWF 0x01 , W
    MOVWF 0x01
    MOVFF PRODH , 0x00
    
    
    NOP
    end



