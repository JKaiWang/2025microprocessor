List p=18f4520
    #include<pic18f4520.inc>

        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00

;-------------------------------------------------
; 16-bit Signed Multiply
;   A = (Ah:Al) 16-bit signed
;   B = (Bh:Bl) 16-bit signed
;   Product = (P4:P3:P2:P1) 32-bit signed result
;   Big endian output (P4 = MSB, P1 = LSB)
;-------------------------------------------------
#define Ah      0x10
#define Al      0x11
#define Bh      0x12
#define Bl      0x13
#define P4      0x20	; MSB
#define P3      0x21
#define P2      0x22
#define P1      0x23	; LSB
#define SIGN    0x18    ; sign flag
GOTO main
_mul16:
    CLRF    SIGN        ; clear sign flag

    ; handle sign of A
    BTFSC   Ah,7        ; if A negative
    INCF    SIGN,F      ; SIGN++
    BTFSC   Ah,7
    RCALL   NegA        ; make A positive

    ; handle sign of B
    BTFSC   Bh,7        ; if B negative
    XORLW   1           ; toggle sign if needed
    BTFSC   Bh,7
    RCALL   NegB        ; make B positive
    ; XOR result of Bh test into SIGN
    BTFSC   Bh,7
    INCF    SIGN,F

    ; clear product registers
    CLRF    P1
    CLRF    P2
    CLRF    P3
    CLRF    P4

    ;----------------------
    ; P1 = Al * Bl
    ;----------------------
    MOVF    Al,W
    MULWF   Bl
    MOVFF   PRODL,P1    ; lowest byte
    MOVFF   PRODH,P2

    ;----------------------
    ; P2 = Al * Bh
    ;----------------------
    MOVF    Al,W
    MULWF   Bh
    MOVF    PRODL,W
    ADDWF   P2,F
    MOVF    PRODH,W
    ADDWFC  P3,F
    BTFSC   STATUS,0
    INCF    P4,F

    ;----------------------
    ; P3 = Ah * Bl
    ;----------------------
    MOVF    Ah,W
    MULWF   Bl
    MOVF    PRODL,W
    ADDWF   P2,F
    MOVF    PRODH,W
    ADDWFC  P3,F
    BTFSC   STATUS,0
    INCF    P4,F

    ;----------------------
    ; P4 = Ah * Bh
    ;----------------------
    MOVF    Ah,W
    MULWF   Bh
    MOVF    PRODL,W
    ADDWF   P3,F
    MOVF    PRODH,W
    ADDWFC  P4,F

    ;----------------------
    ; if SIGN != 0, negate result (two's complement)
    ;----------------------
    MOVF    SIGN,W
    BTFSC   STATUS,2
    RETURN              ; no sign change

    ; invert P1..P4
    COMF    P1,F
    COMF    P2,F
    COMF    P3,F
    COMF    P4,F
    INCF    P1,F
    BTFSC   STATUS,0
    INCF    P2,F
    BTFSC   STATUS,0
    INCF    P3,F
    BTFSC   STATUS,0
    INCF    P4,F

    RETURN

NegA:
    COMF    Al,F
    COMF    Ah,F
    INCF    Al,F
    BTFSC   STATUS,0
    INCF    Ah,F
    RETURN
NegB:
    COMF    Bl,F
    COMF    Bh,F
    INCF    Bl,F
    BTFSC   STATUS,0
    INCF    Bh,F
    RETURN
;-------------------------------------------------
main:
    ; Test values: A = -300 (0xFED4), B = 200 (0x00C8)
    ; Expected result = -60000(0xFF15A0)
    MOVLW   LOW 0xFED4
    MOVWF   Al
    MOVLW   HIGH 0xFED4
    MOVWF   Ah

    MOVLW   LOW 0x00C8
    MOVWF   Bl
    MOVLW   HIGH 0x00C8
    MOVWF   Bh

    CALL    _mul16

    NOP
    END