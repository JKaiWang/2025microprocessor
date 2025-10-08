#INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF 
    org 0x00    ;PC = 0x10 
    ;ABCD EFGH -> EFGH ABCD
    ; swap four bit : (high nibble | low nibble ) -> (low nibble | high nibble)
    MOVLW 0xA6 ; 01011011 10100110
    MOVWF TRISA
    SWAPF TRISA , W
    MOVWF TRISA
    
    ; now will be 10110101
    ; swap two bit : 
    ; EFGH ABCD -> GHEF CDAB
    MOVLW b'11001100' ; 11001100
    ANDWF TRISA , W ; 10000100
    RRNCF WREG ; 01
    RRNCF WREG 
    MOVWF 0x01 ; 
    MOVLW b'00110011'
    ANDWF TRISA , W 
    RLNCF WREG
    RLNCF WREG
    MOVWF 0x02
    MOVF 0x01 , WREG 
    ADDWF 0x02
    MOVF 0x02 , WREG
    MOVWF TRISA
    ;now 11100101
    ;next we will swap in one bit such as GHEF CDAB-> HGFE DCBA 
    MOVLW b'10101010' ; 10100000
    ANDWF TRISA , W
    RRNCF WREG
    MOVWF 0x01
    MOVLW b'01010101'
    ANDWF TRISA , W
    RLNCF WREG
    ADDWF 0x01
    MOVF 0x01 , W 
    MOVWF TRISA
    
    end
    
    
    


