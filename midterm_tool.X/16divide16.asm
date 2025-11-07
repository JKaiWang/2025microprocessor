    LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    Divide_high EQU 0x00
    Divide_low	EQU 0x01
    Divisor_high    EQU 0x02
    Divisor_low	EQU 0x03
    Quotient_high   EQU 0x10
    Quotient_low    EQU 0x11
    Remainder_high  EQU 0x12
    Remainder_low   EQU 0x13
    ;SUBWF  use f - wreg
    ;dividend same mark with remainder
    ; divisor same mark with quotient
    MOVLW   0x9D
    MOVWF   Divide_high       ; Dividend high
    MOVLW   0x80
    MOVWF   Divide_low       ; Dividend low
    MOVLW   0x
    MOVWF   Divisor_high       ; Divisor high
    MOVLW   0x22
    MOVWF   Divisor_low       ; Divisor low

    CALL    division
    NOP
    SLEEP

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
    NOP
    END