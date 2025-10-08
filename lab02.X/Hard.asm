LIST    P=18F4520
#include <p18f4520.inc>
CONFIG OSC = INTIO67
CONFIG WDT = OFF
ORG 0x00

input   EQU 0x310 ; input array base address'
output  EQU 0x320 ; output array base address (8byte)
flag    EQU 0x330 ; flag array(mark used elements)

;temporary register
temp0   EQU 0x20
temp1   EQU 0x21
temp2   EQU 0x22
temp3   EQU 0x23
idx     EQU 0x24 ; index variable
head    EQU 0x25 ; output head pointer
tail    EQU 0x26 ; output tail pointer
minval  EQU 0x27 ; currently found minimum value
minpos  EQU 0x28 ; position of current minimum

; Program Start
start:
    ;  Load Testcase1 data into input[0x310~0x317] 
    LFSR    0, input
    MOVLW   0xC4
    MOVWF   POSTINC0
    MOVLW   0xBB
    MOVWF   POSTINC0
    MOVLW   0xBB
    MOVWF   POSTINC0
    MOVLW   0x00
    MOVWF   POSTINC0
    MOVLW   0x4C
    MOVWF   POSTINC0
    MOVLW   0x8B
    MOVWF   POSTINC0
    MOVLW   0xBB
    MOVWF   POSTINC0
    MOVLW   0x00
    MOVWF   POSTINC0

    ;  Initialize head=0/tail=7 
    CLRF head
    MOVLW 0x07
    MOVWF tail

    ;  Clear flag : flag[0:7] = 0
    LFSR 0, flag
    MOVLW 0x08
    MOVWF temp0
clr_flag:
    CLRF INDF0
    INCF FSR0L, F
    DECF temp0, F
    BNZ clr_flag

; Main Loop
main_loop:
    ; if head > tail ? exit loop
    MOVF head, W
    SUBWF tail, W
    BNC main_loop_exit   ; exit loop when head > tail
    
    
    
;find min value
    MOVLW 0xFF
    MOVWF minval
    CLRF idx
find_min:
    ; check flag[idx] 
    MOVLW   low flag
    ADDWF   idx, W
    MOVWF   FSR1L
    MOVLW   high flag
    MOVWF   FSR1H
    MOVF    INDF1, W
    BNZ     next_min ; skip if already used

    ;Loop input[idx]
    MOVLW   low input
    ADDWF   idx, W
    MOVWF   FSR1L
    MOVLW   high input
    MOVWF   FSR1H
    MOVF    INDF1, W
    MOVWF   temp1

    ; compare with current minval
    MOVF    temp1, W
    SUBWF   minval, W
    BNC     next_min  ; if temp1 >= min value , skip 
    MOVF    temp1, W
    MOVWF   minval ; update new minval
    MOVF    idx, W
    MOVWF   minpos ; update minpos

next_min:
    INCF idx, F
    MOVLW 0x08
    CPFSEQ idx
    GOTO find_min

    ; Mark flag[minpos] = 1
    MOVLW   low flag
    ADDWF   minpos, W
    MOVWF   FSR1L
    MOVLW   high flag
    MOVWF   FSR1H
    MOVLW   0x01
    MOVWF   INDF1

; Step 2: find partners (nibble reversed)
    ; Extract high nibble of minval -> temp0
    MOVF    minval, W
    MOVWF   temp2
    SWAPF   temp2, W
    ANDLW   0x0F
    MOVWF   temp0

    ; Extract low nibble of  minval -> temp1
    MOVF    minval, W
    ANDLW   0x0F
    MOVWF   temp1

    ; ready to seaech the partner
    CLRF idx
find_partner:
    ;first check the flag[idx] whether the value is being used or not
    MOVLW   low flag ; take out the low address from flag
    ; idx + working register(flag's low address)
    ; checkout that the the truly position of number 
    ADDWF   idx, W 
    MOVWF   FSR1L
    MOVLW   high flag
    MOVWF   FSR1H
    MOVF    INDF1, W
    BNZ     next_partner

    ;Load input[idx] -> temp2 
    ;WREG will be overwritten by later operations 
    ;(SWAPF ANDLW e.t.c...)
    ;compare both nibbles with minvalue
    ;to make sure that it's partnerr can put into output
    MOVLW   low input
    ADDWF   idx, W
    MOVWF   FSR1L
    MOVLW   high input
    MOVWF   FSR1H
    MOVF    INDF1, W
    MOVWF   temp2

    ;check whether it partner nibble match
    ; extract high nipple of temp2 and compare with minval.low
    MOVF    temp2, W
    MOVWF   temp3
    SWAPF   temp3, W ; swap nibbles , high nibbles move to low bits
    ANDLW   0x0F; mask to keep onlu low nibbles
    CPFSEQ  temp1 ; if temp2.high!= minvalue ->no partner
    GOTO    next_partner

    MOVF    temp2, W
    ANDLW   0x0F
    CPFSEQ  temp0
    GOTO    next_partner

    ; ?? partner ? ?? flag
    MOVLW   low flag
    ADDWF   idx, W
    MOVWF   FSR1L
    MOVLW   high flag
    MOVWF   FSR1H
    MOVLW   0x01
    MOVWF   INDF1
    GOTO    found_partner

next_partner:
    INCF idx, F
    MOVLW 0x08
    CPFSEQ idx
    GOTO find_partner
    GOTO fail_case

found_partner:
; 
; Step 3: ?? output
    MOVF    minval, W
    SUBWF   temp2, W       ; W = minval - partner
    BNC     partner_smaller

; ??1: minval < partner ? minval ? head, partner ? tail
    MOVLW   low output
    ADDWF   head, W
    MOVWF   FSR0L
    MOVLW   high output
    MOVWF   FSR0H
    MOVF    minval, W
    MOVWF   INDF0

    MOVLW   low output
    ADDWF   tail, W
    MOVWF   FSR0L
    MOVLW   high output
    MOVWF   FSR0H
    MOVF    temp2, W
    MOVWF   INDF0
    GOTO update_pointer

partner_smaller:
; ??2: partner < minval ? partner ? head, minval ? tail
    MOVLW   low output
    ADDWF   head, W
    MOVWF   FSR0L
    MOVLW   high output
    MOVWF   FSR0H
    MOVF    temp2, W
    MOVWF   INDF0

    MOVLW   low output
    ADDWF   tail, W
    MOVWF   FSR0L
    MOVLW   high output
    MOVWF   FSR0H
    MOVF    minval, W
    MOVWF   INDF0


update_pointer:
    INCF head, F
    DECF tail, F
    GOTO main_loop
; Main Loop Exit ? ???????
main_loop_exit:
    GOTO done

; 
; Fail Case
; 
fail_case:
    LFSR 0, output
    MOVLW 0x08
    MOVWF temp0
fill_ff:
    MOVLW 0xFF
    MOVWF INDF0
    INCF FSR0L, F
    DECF temp0, F
    BNZ fill_ff
    GOTO finish

done:
    ; palindrome ??
    NOP

finish:
    END
