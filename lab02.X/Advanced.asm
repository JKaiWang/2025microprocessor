LIST    P=18F4520
    #include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
AStart	EQU 0x200
AEnd	EQU 0x206
BStart	EQU 0x210
BEnd	EQU 0x215
Final_sequence    EQU 0x220 
Final_end   EQU 0x22A
tempA	EQU 0x00
tempB	EQU 0x01

intitialize:
    LFSR 0, AStart
    LFSR 1, BStart
    LFSR 2, Final_sequence
loadA:
    MOVLW 0x00
    MOVWF POSTINC0 ; store wreg at [FSR0] and then FSR0 = FSR0+1
    MOVLW 0x33
    MOVWF POSTINC0
    MOVLW 0x58
    MOVWF POSTINC0
    MOVLW 0x7A
    MOVWF POSTINC0
    MOVLW 0xC4
    MOVWF POSTINC0
    MOVLW 0xF0
    MOVWF POSTINC0
loadB:
    MOVLW 0x09
    MOVWF POSTINC1
    MOVLW 0x58
    MOVWF POSTINC1
    MOVLW 0x6E
    MOVWF POSTINC1
    MOVLW 0xB8
    MOVWF POSTINC1
    MOVLW 0xDD
    MOVWF POSTINC1
    
    
    LFSR 0, AStart
    LFSR 1, BStart
    LFSR 2, Final_sequence
    
    
compareAB:
    MOVLW   AEnd
    CPFSEQ  FSR0L
    GOTO    check_B_end
    GOTO    copy_rest_B

check_B_end:
    MOVLW   BEnd
    CPFSEQ  FSR1L
    GOTO    do_compare
    GOTO    copy_rest_A

do_compare:
    MOVF    INDF0, W
    MOVWF   tempA
    MOVF    INDF1, W
    MOVWF   tempB

    MOVF    tempA, W
    CPFSEQ  tempB
    GOTO    not_equal

equal_case:
    MOVF tempA, W
    MOVWF POSTINC2
    INCF FSR0L, F
    
    ;MOVF tempB, W 
    ;MOVWF POSTINC2
    ;INCF FSR1L, F
    GOTO compareAB
not_equal:
    MOVF tempA, W
    CPFSGT tempB ; skip if B> A
    GOTO B_less
A_less:
    MOVF tempA,W
    MOVWF POSTINC2
    INCF FSR0L, F
    GOTO compareAB
B_less:
    MOVF tempB, W
    MOVWF POSTINC2
    INCF FSR1L, F
    GOTO compareAB
copy_rest_A:
    MOVF    INDF0, W
    MOVWF   POSTINC2
    INCF    FSR0L, F       
    MOVLW   LOW AEnd
    CPFSEQ  FSR0L
    GOTO    copy_rest_A
    MOVLW   HIGH AEnd
    CPFSEQ  FSR0H
    GOTO    copy_rest_A

    GOTO    end_merge
    
    
copy_rest_B:
    MOVF    INDF1, W
    MOVWF   POSTINC2
    INCF    FSR1L, F       
    MOVLW   LOW BEnd
    CPFSEQ  FSR1L
    GOTO    copy_rest_B
    MOVLW   HIGH BEnd
    CPFSEQ  FSR1H
    GOTO    copy_rest_B

    GOTO    end_merge
end_merge:
    end
    
    

