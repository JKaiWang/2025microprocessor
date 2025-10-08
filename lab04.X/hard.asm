    LIST    P=18F4520
    #include <p18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00

; ===== Test Data =====
    MOVLW   0xFE
    MOVWF   0x020           ; N high
    MOVLW   0x01
    MOVWF   0x021           ; N low
    MOVLW   0x55
    MOVWF   0x022           ; x0 high
    MOVLW   0x66
    MOVWF   0x023           ; x0 low

    GOTO    newtonSqrt


; ===== Division (no RETURN) =====
division:
    CLRF    0x010
    CLRF    0x011
    MOVFF   0x000, 0x012
    MOVFF   0x001, 0x013
div_loop:
    MOVF    0x003, W
    SUBWF   0x013, F        ; low byte subtraction
    MOVF    0x002, W
    SUBWFB  0x012, F        ; high byte subtraction with borrow
    BTFSS   STATUS, C        ; if borrow set (C=0) ? end
    GOTO    div_done

    INCF    0x011, F        ; increment quotient low
    BTFSC   STATUS, Z
    INCF    0x010, F        ; handle carry to high byte
    GOTO    div_loop

div_done:
    GOTO    div_back_to_newton
    


; ===== Newton?s Method =====
newtonSqrt:
    MOVFF 0x022 , 0x070     ; x high
    MOVFF 0x023 , 0x071     ; x low
    CLRF  0x076             ; iteration counter

ns_iter:
    INCF  0x076, F
    ; ===== q = N / x =====
    MOVFF  0x020, 0x000
    MOVFF  0x021, 0x001
    MOVFF  0x070, 0x002
    MOVFF  0x071, 0x003
    GOTO   division

div_back_to_newton:
    MOVFF  0x010, 0x072     ; q high
    MOVFF  0x011, 0x073     ; q low

    ; ===== s = x + q =====
    MOVF   0x073, W
    ADDWF  0x071, F
    MOVF   0x072, W
    ADDWFC 0x070, F

    ; ===== x_next = s / 2 (?????) =====
    BCF STATUS, C            ; clear carry to ensure floor division
    RRCF 0x070, F
    RRCF 0x071, F

    ; ===== ???? x_next == x =====
    MOVF 0x071, W
    XORWF 0x023, W
    BNZ ns_update
    MOVF 0x070, W
    XORWF 0x022, W
    BNZ ns_update

converged:
    MOVFF 0x070, 0x024       ; ?N high
    MOVFF 0x071, 0x025       ; ?N low
    GOTO  end_program

ns_update:
    MOVFF 0x070, 0x022        ; x = x_next (high)
    MOVFF 0x071, 0x023        ; x = x_next (low)
    MOVLW 0x32                ; max 50 iterations
    CPFSGT 0x076
    GOTO ns_iter
    GOTO converged

end_program:
    NOP
    END
