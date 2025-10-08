    LIST    P=18F4520
    #include <p18f4520.inc>

    CONFIG OSC = INTIO67
    CONFIG WDT = OFF

    ORG 0x00

  x1      EQU 0x00
  x2      EQU 0x01	
  y1      EQU 0x02
  y2      EQU 0x03
  A1      EQU 0x10
  A2      EQU 0x11
  result  EQU 0x20
  
  MOVLW 0xB6
  ;MOVLW 0x08
  MOVWF x1
  MOVLW 0x0C
  ;MOVLW 0x08
  MOVWF x2
  MOVLW 0xD3
  ;MOVLW 0x0F
  MOVWF y1
  MOVLW 0xB7
  ;MOVLW 0x02
  MOVWF y2
  
  ; x1+x2 move into A1
  MOVF x2,W
  ADDWF x1, W
  MOVWF A1
  CLRF WREG
  
  ; y1-y2 and move into A2
  MOVF y2,W
  SUBWF y1 ,W
  MOVWF A2
  CLRF WREG
  
  ; if A1>A2 output 0xFF
  ; if A2>A1 output 0x01
  MOVF A1,W
  CPFSGT A2 ; compare A2 with WREG(A1) , skip if A2>A1
  GOTO output_0xFF
  GOTO output_0x01
  
  output_0xFF: 
    MOVLW 0xFF
    MOVWF result
    GOTO EndP
    
  output_0x01:
    MOVLW 0x01
    MOVWF result
    GOTO EndP
  EndP:
    end
  
  
  
  

  
