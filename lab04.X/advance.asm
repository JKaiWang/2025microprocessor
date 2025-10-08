    LIST    P=18F4520
    #include <p18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00


    MOVLW   0x01
    MOVWF   0x00       ; Dividend high
    MOVLW   0xF4
    MOVWF   0x01       ; Dividend low
    MOVLW   0x00
    MOVWF   0x02       ; Divisor high
    MOVLW   0x22
    MOVWF   0x03       ; Divisor low

    CALL    division
    NOP
    SLEEP

division:
    CLRF    0x010      ; Quotient high
    CLRF    0x011      ; Quotient low

    MOVFF   0x000, 0x012   ; Remainder high = Dividend high
    MOVFF   0x001, 0x013   ; Remainder low  = Dividend low

div_loop:
    
    ; check remainder < divisor ?
    MOVF    0x003, W
    SUBWF   0x013, W
    MOVWF   0x070           ; store temporarily
    MOVF    0x002, W
    SUBWFB  0x012, W
    BTFSS   STATUS, C       ; if C=0?means that remainder < divisor
    GOTO    div_done

    
    ; remainder = remainder - divisor
    MOVF    0x003, W
    SUBWF   0x013, F
    MOVF    0x002, W
    SUBWFB  0x012, F

    
    ; quotient++
    INCF    0x011, F
    BTFSC   STATUS, Z
    INCF    0x010, F

    GOTO    div_loop

div_done:
    NOP
    END
