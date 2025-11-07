LIST    P=18F4520
	#include <pic18f4520.inc>
    CONFIG  OSC = INTIO67
    CONFIG  WDT = OFF
    ORG     0x00
    
main:
    ; 3,5,2,2,4,7
    LFSR 0, 0x10
    MOVLW 0x03
    MOVWF POSTINC0
    MOVLW 0x05
    MOVWF POSTINC0
    MOVLW 0x02
    MOVWF POSTINC0
    MOVLW 0x02
    MOVWF POSTINC0
    MOVLW 0x04
    MOVWF POSTINC0
    MOVLW 0x07
    MOVWF POSTINC0
    MOVLW 0x06
    MOVWF 0x20          ; array size

    CALL _bubble_sort
    GOTO end_program
    NOP
;------------------------------------------------------
; Bubble Sort (ascending)
; Array: starts at 0x10
; Size:  stored at 0x20
;------------------------------------------------------
ARRAY_START    EQU 0x10
ARRAY_SIZE     EQU 0x20
I_REG          EQU 0x21
J_REG          EQU 0x22
TEMP           EQU 0x23
SWAPPED        EQU 0x24
;------------------------------------------------------
; Bubble Sort routine
;------------------------------------------------------
_bubble_sort:
    MOVF    ARRAY_SIZE, W
    BZ      done
    DECF    WREG, F
    MOVWF   I_REG

outer_loop:
    CLRF    SWAPPED
    CLRF    J_REG

inner_loop:
    MOVF    J_REG, W
    ADDLW   ARRAY_START
    MOVWF   FSR0L
    CLRF    FSR0H

    MOVF    INDF0, W
    MOVWF   TEMP
    INCF    FSR0L, F
    MOVF    INDF0, W

    ; if arr[j] > arr[j+1] ? swap
    CPFSLT  TEMP
    BRA     do_swap

no_swap:
    INCF    J_REG, F
    MOVF    I_REG, W
    CPFSLT  J_REG           ; loop only while J < I
	GOTO $+6
	BRA     inner_loop

    MOVF    SWAPPED, F
    BZ      done
    DECF    I_REG, F
    BNZ     outer_loop

done:
    RETURN

do_swap:
    DECF    FSR0L, F
    MOVF    INDF0, W
    MOVWF   TEMP
    INCF    FSR0L, F
    MOVF    INDF0, W
    DECF    FSR0L, F
    MOVWF   INDF0
    INCF    FSR0L, F
    MOVF    TEMP, W
    MOVWF   INDF0
    BSF     SWAPPED, 0
    BRA     no_swap
;------------------------------------------------------

end_program:
    NOP
    END



