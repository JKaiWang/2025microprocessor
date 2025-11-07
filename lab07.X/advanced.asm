LIST p=18f4520 
#include<pic18f4520.inc>

; CONFIG1H
    MODE EQU 0X030
 COUNT EQU 0X031
 
  CONFIG  OSC = INTIO67         ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)

  MOVLF macro literal, FileReg
 MOVLW literal
 MOVWF FileReg
    endm
  
  
    org 0x00
    
goto Initial       
ISR:    
    org 0x08                ; 
    MOVLW 0X00
    CPFSEQ COUNT
    GOTO KEEP
    MOVLW 0X10
    MOVWF COUNT  
   
    KEEP:
    DECF COUNT
    BTG MODE,0
    
    SWAPF COUNT,W
    MOVWF LATD
    
    MOVLW 0X00
    CPFSEQ MODE
    GOTO ONE
    GOTO HALF
    
    ONE:
;    MOVLW 0XFF
;    MOVWF LATD
    MOVLW 244
    MOVWF PR2 
    GOTO finish
    HALF:
;    MOVLW 0X03
;    MOVWF LATD
    MOVLW 122
    MOVWF PR2 
    finish:
    BCF PIR1, 1 
    
    
    RETFIE
    
Initial:   
    MOVLW 0x0F
    MOVWF ADCON1
    CLRF TRISD
    CLRF LATD
    BSF RCON, 7
    BSF INTCON,7
    BCF PIR1, 1  ; ????TIMER2??????????TMR2IF?TMR2IE?TMR2IP?
    BSF IPR1, 1
    BSF PIE1 , 1
    MOVLW 0b11111111         ; ?Prescale?Postscale???1:16???????256??????TIMER2+1
    MOVWF T2CON  ; ???TIMER?????????/4????????
    MOVLW 122  ; ???256 * 4 = 1024?cycles???TIMER2 + 1
    MOVWF PR2   ; ??????250khz???Delay 0.5?????????125000cycles??????Interrupt
    ; ??PR2??? 125000 / 1024 = 122.0703125? ???122?
    MOVLW 0b00100000
    MOVWF OSCCON         ; ??????????250kHz
    
    MOVLW 0X10
    MOVWF COUNT   
    MOVLW 0X01
    MOVWF MODE
main:
    
    bra main     

    
end