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
    MOVWF 0x10
    MOVLW 0x00
    MOVWF 0x11
    MOVLW 0x02
    MOVWF 0x20
    MOVLW 0x00
    MOVWF 0x21
    
    Ghigh  EQU 0x00
    Glow    EQU 0x01
    
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
	GOTO end_program
	
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
    MOVWF   0x070           ; store temporarily
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
	
	
    end_program:
	MOVFF 0x20 , Ghigh
	MOVFF 0x21 , Glow
	NOP
	end
    
	


