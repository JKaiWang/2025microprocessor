    LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    input   EQU 0x20
    output  EQU 0x00
    remainder	EQU 0x22
    divisor EQU 0x21
    MOVLW 0x02
    MOVWF input
    
    MOVLW 0x01 
    CPFSGT input ; if 0x20 >0x01 ,skip next line
    GOTO not_prime
    
    MOVLW 0x02
    MOVWF divisor
    
check_next_i:
    MOVF divisor ,W 
    CPFSGT input  ; if input > divisor, skip next line
    GOTO is_prime
    MOVFF input , remainder


div_loop:
    MOVF divisor ,W
    SUBWF remainder 
    BTFSS STATUS , 0
    GOTO div_done
    MOVF remainder , W 
    BZ not_prime
    GOTO div_loop
div_done:
    INCF divisor ,F ; divisor ++ return back to check_next_i
    GOTO check_next_i
is_prime:
    MOVLW 0x01
    MOVWF output
    GOTO return_program

    
not_prime:
    MOVLW 0xFF
    MOVWF output
    GOTO return_program

return_program:
    NOP
    END


