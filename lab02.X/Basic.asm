LIST    P=18F4520
    #include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    address0	EQU 0x120 ; number 1
    address1	EQU 0x121 ; number 2
    address2	EQU 0x122 ; start to compute
    address6	EQU 0x126 ; stop computing at this addrss
    temp0    EQU 0x20 ; using to temporary storage for[addr-2]
    temp1    EQU 0x21 ; using to temporary storage for[addr-1]
    ; using FSRS to get the indirect address 
    
    start:
	; Point FSR0 to 0x120
	LFSR 0, address0
	
	;testcase 0x120 
	MOVLW 0x8E ; load immediate value 0x02
	
	;store WREG into memory at [0x120]
	MOVWF INDF0 ; [0x120] = 2
	
	; Increment pointer now FSR0 points to 0x121
	INCF FSR0L , F ; move pointer to 0x121
	MOVLW 0x37
	MOVWF INDF0 ; [0x121] = 3
	
	;set pointer to 0x122, the start of the computation range
	LFSR    0, address2   
	
	
    loop_calc:
	; get [addr-2] ? temp 0
	MOVFF FSR0L , FSR1L ; copy FSR0L -> FSR1L
	MOVFF FSR0H , FSR1H ; copy FSR0H -> FSR1H
	DECF FSR1L, F ; FSR1 = FSR0-1
	DECF FSR1L, F ; FSR1 = FSR0-2
	MOVF INDF1, W ; WREG = value at [addr-2]
	MOVWF temp0 ; store into temp0

	; get [addr-1] ? temp 0x21
	MOVFF FSR0L, FSR1L
	MOVFF FSR0H, FSR1H
	DECF FSR1L, F
	MOVF INDF1, W
	MOVWF temp1

	; check even / odd
	MOVF    FSR0L, W
	ANDLW   0x01
	BNZ     IS_ODD
   
    IS_EVEN:
	; [addr] = [addr-2]+[adder-1]
	MOVF 0x20, W
	ADDWF 0x21,W
	MOVWF INDF0
	BRA NEXT
    
    IS_ODD:
	;[addr] = [addr-2]-[addr-1]
	MOVF    temp1, W        ; W = [addr-1]
	SUBWF   temp0, W        ; W = [addr-2] - [addr-1]
	MOVWF   INDF0
    NEXT:
	;move to next address
	INCF FSR0L, F
	MOVLW LOW(address6+1)
	CPFSEQ FSR0L
	BRA loop_calc
	
	end


