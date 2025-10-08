    LIST    P=18F4520
    #include <p18f4520.inc>

    CONFIG OSC = INTIO67
    CONFIG WDT = OFF

    ORG 0x00
INPUT   EQU 0x00
COUNT   EQU 0x10
TEMP    EQU 0x01

;input
    MOVLW   b'00000000'
    MOVWF   INPUT

; CLZ

    CLRF    COUNT

    ;special ex : 00000000
    MOVF    INPUT, W
    BNZ     check_loop     ;if temp !=0 goto check_loop
    MOVLW   d'8'           ; if TEMP = 0?leading zero = 8
    MOVWF   0x010
    GOTO    program_end

check_loop:
    BTFSC   INPUT, 7 ; if bit 7 =0 skip next line
    GOTO    found_one
    
    INCF    COUNT, F ;count +=1
    RLNCF   INPUT, F ; rotate temp 
    GOTO    check_loop 

found_one:
    MOVF    COUNT, W
    MOVWF   0x010 

program_end:
    END
