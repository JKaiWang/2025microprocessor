List p=18f4520
    #include<pic18f4520.inc>

        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00

        MOVLW 0x0F 
     MOVWF 0x10 ;input /n

        MOVLW 0x08 
     MOVWF 0x11 ;input /k

        CLRF 0x20 ;n! high
        CLRF 0x21 ;n! low
        CLRF 0x30 ;k! * n-k! high
        CLRF 0x31 ;k! * n-k! low
 CLRF 0x50
 CLRF 0x51
 CLRF 0x00
 CLRF 0x01
 CLRF 0x60
 CLRF 0x61
 CLRF 0x40
 CLRF 0x41
 CLRF 0x43
 
 MOVLW 0x01
 MOVWF 0x21
 MOVWF 0x31

        MOVFF 0x10, 0x40
        RRCF 0x40
        MOVF 0x40, w
        CPFSGT  0x11
        GOTO CALL_FACT
        MOVF 0x11,w
        MOVFF 0x10,0x11
        SUBWF 0x11

    CALL_FACT:
        RCALL Fact
        GOTO FINISH

    Fact:
        INCF 0x11

        LOOP:
                DECFSZ  0x11
                GOTO CONT
                CLRF 0x50
                CLRF 0x51
                GOTO DIV
        CONT:
                
                MOVF 0x10,w
                MULWF 0x21
                MOVFF PRODL, 0x41
                MOVFF PRODH, 0x40

                MOVF 0x10,w
                MULWF 0x20
                MOVFF PRODL, 0x43

                MOVFF 0x41,0x21
                MOVF 0x40,w
                MOVFF 0x43,0x20
                ADDWF 0x20
                DECF 0x10

                MOVFF 0x20, 0x60
                MOVFF 0x21,0x61
  CLRF 0x50
  CLRF 0x51
  MOVLW 0x01
  CPFSEQ 0x11
  GOTO SUB
  GOTO DIV

        SUB:
                INCF 0x51
                BTFSC   STATUS,0
                INCF 0x50

                MOVF 0x11,w
                SUBWF 0x61
  MOVF 0x00,w
                SUBWFB 0x60,f
                BTFSS   STATUS,0
                GOTO MUL_K
                MOVLW 0x00
                CPFSEQ  0x61
                GOTO SUB
                CPFSEQ  0x60
                GOTO SUB
                MOVFF 0x51,0x21
                MOVFF 0x50,0x20
                GOTO LOOP
        
        MUL_K:
                MOVF 0x11,W
                MULWF 0x31
                MOVFF PRODL, 0x41
                MOVFF PRODH, 0x40

                MOVF 0x11,w
                MULWF 0x30

                MOVFF PRODL, 0x43

                MOVFF 0x41,0x31
                MOVF 0x40,w
                MOVFF 0x43,0x30
                ADDWF 0x30
                GOTO LOOP
            
        DIV:
                BCF STATUS,0
                MOVF 0x31,w
                SUBWF 0x21,f
                MOVF 0x30,w
                SUBWFB 0x20,f

                BTFSS   STATUS, 0         
                GOTO    DIV_END

                INCF 0x51
                BTFSC   STATUS, 0
                INCF 0x50
                GOTO DIV

        DIV_END:
            MOVFF 0x50,0x00
            MOVFF 0x51,0x01
            RETURN
            
        FINISH:
    NOP

end