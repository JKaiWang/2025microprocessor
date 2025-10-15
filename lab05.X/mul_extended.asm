#include "xc.inc"
GLOBAL _mul_extended
PSECT mytext, local, class=CODE, reloc=2

_mul_extended:
    CLRF 0x20 
    
    ; check sign of n 
    BTFSS  0x02 , 7
    BRA check_m
    COMF 0x01 
    COMF 0x02
    INCF 0x01
    BTFSC STATUS , 0
    INCF 0x02
    BSF 0x20 , 0
check_m:
    ; check sign of m
    BTFSS 0x04 , 7
    BRA mul_unsigned
    COMF 0x03 
    COMF 0x04
    INCF 0x03
    BTFSC STATUS , 0 
    INCF 0x04
    BTG 0x20, 0

mul_unsigned:
    CLRF 0x10
    CLRF 0x11
    CLRF 0x12 
    CLRF 0x13
    ; nL * mL 
    MOVF 0x01 ,W
    MULWF 0x03
    MOVFF PRODL , 0x10
    MOVFF PRODH, 0x11
    ;nL*mH
    MOVF 0x01 , W
    MULWF 0x04 
    MOVF PRODL , W 
    ADDWF 0x11 
    BTFSC STATUS , 0
    INCF 0x12
    MOVF PRODH , W
    ADDWF 0x12
    BTFSC STATUS, 0
    INCF 0x13
    ;nH*mL
    MOVF 0x02, W
    MULWF 0x03
    MOVF PRODL ,W
    ADDWF 0x11
    BTFSC STATUS , 0
    INCF 0x12
    MOVF PRODH ,W
    ADDWF 0x12,F
    BTFSC STATUS,0
    INCF 0x13
    ;nH*mH
    MOVF 0x02 , W
    MULWF 0x04
    MOVF PRODL , W
    ADDWF 0x12
    BTFSC STATUS ,0
    INCF 0x13
    MOVF PRODH , W
    ADDWF 0x13
    
    ; apply sign if negative
    BTFSS 0x20 , 0
    BRA done
    COMF 0x10 
    COMF 0x11
    COMF 0x12 
    COMF 0x13
    INCF 0x10
    BTFSC STATUS ,0
    INCF 0x11
    BTFSC STATUS , 0
    INCF 0x12
    BTFSC STATUS , 0
    INCF 0x13
    
done:
    MOVFF 0x10 , 0x01
    MOVFF 0x11 , 0x02
    MOVFF 0x12 , 0x03
    MOVFF 0x13 , 0x04
    NOP
    RETURN
    
    