    LIST p=18f4520
    #include <pic18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

; ===== input =====   
; dividend low  -> 0x01
; dividend high -> 0x00
; divisor       -> 0x10
    
; ===== output =====
; quotient_high -> 0x20 
; quotient_low  -> 0x21 
; remainder     -> 0x30

    ; input testcase
    MOVLW 0x20
    MOVWF 0x01          ; low
    MOVLW 0x20
    MOVWF 0x00          ; high
    MOVLW 0x03
    MOVWF 0x10

_div16by8_simple:
    CLRF 0x20           ; quotient_high = 0
    CLRF 0x21           ; quotient_low  = 0

    MOVF 0x01, W
    MOVWF 0x30           ; remainder_low  = dividend_low
    MOVF 0x00, W
    MOVWF 0x31           ; remainder_high = dividend_high

div_loop:
    ; check if remainder < divisor
    MOVF 0x31, W
    BNZ can_sub           ; ? high ? 0 ? ??
    MOVF 0x30, W
    SUBWF 0x10, W
    BNC done_div          ; ? remainder < divisor ? ??

can_sub:
    ; remainder -= divisor
    MOVF 0x10, W
    SUBWF 0x30, F
    BTFSC STATUS, 0       ; ????(C=0)???? -1
    GOTO skip_borrow
    DECF 0x31, F
skip_borrow:

    ; quotient++
    INCF 0x21, F
    BTFSC STATUS, 2
    INCF 0x20, F

    GOTO div_loop

done_div:
    ; ??????
    MOVF 0x30, W
    MOVWF 0x30
    CLRF 0x31

    NOP
    END
