#include "xc.inc"
GLOBAL _is_prime
PSECT mytext, local, class=CODE, reloc=2
 
 
_is_prime:
    MOVWF 0x20
    
    MOVLW 0x01 
    CPFSGT 0x20
    GOTO not_prime
    
    MOVLW 0x02
    MOVWF 0x21
    
check_next_i:
    MOVF 0x21 ,W 
    CPFSGT 0x20 
    GOTO is_prime
    MOVFF 0x20 , 0x22


div_loop:
    MOVF 0x21 ,W
    SUBWF 0x22 
    BTFSS STATUS , 0
    GOTO div_done
    MOVF 0x22 , W 
    BZ not_prime
    GOTO div_loop
div_done:
    INCF 0x21 ,F
    GOTO check_next_i
is_prime:
    MOVLW 0x01
    GOTO return_program

    
not_prime:
    MOVLW 0xFF
    GOTO return_program

return_program:
    NOP
    RETURN
    


