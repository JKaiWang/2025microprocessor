List p=18f4520 
    #include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    input EQU 0x000
    result EQU 0x010
    MOVLW b'11111111'
    MOVWF input
    
    MOVLW 0x00
    MOVWF result

high4:
    CLRF WREG
    MOVLW 0x10 
    CPFSLT input ; less then 0x010 skip next line f<W(00010000) 
    GOTO high2
    MOVLW 0x04
    ADDWF result
    RLNCF input
    RLNCF input
    RLNCF input
    RLNCF input
high2:
    CLRF WREG
    MOVLW 0x40 
    CPFSLT input; less then 0x010 skip next line f<W(00100000)
    GOTO high1
    CLRF WREG
    MOVLW 0x02
    ADDWF result
    RLNCF input
    RLNCF input
 
high1:
    CLRF WREG
    MOVLW 0x80 ; less then 0x80 skip next line f<W(10000000)
    CPFSLT input
    GOTO end_result
    CLRF WREG
    INCF 0x010
    RLNCF input
    
end_result:
    BTFSS input , 7
    INCF result
    
end


