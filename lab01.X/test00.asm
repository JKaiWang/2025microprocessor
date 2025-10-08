List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00

	initial: 
	    MOVLW 0x04
	    MOVWF 0x00
	    MOVLW 0x1
	start:
	    DECFSZ 0x00
	    GOTO start
	 
	end