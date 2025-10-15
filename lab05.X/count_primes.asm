#include <xc.inc>

    GLOBAL _count_primes
    PSECT text, class=CODE, reloc=2
    BCF WDTCON , 0
Z   EQU 2

; ======================================================
; Entry: _count_primes (n=[0x01:0x02], m=[0x03:0x04])
; ======================================================
_count_primes:
    ; ? m == 0xFFFF ? ?? 0xFFFE
    MOVF 0x03, W, A
    XORLW 0xFF
    BNZ skip_fix_m
    MOVF 0x04, W, A
    XORLW 0xFF
    BNZ skip_fix_m
    MOVLW 0xFE
    MOVWF 0x03, A
    MOVLW 0xFF
    MOVWF 0x04, A
skip_fix_m:
    CLRF 0x10, A
    CLRF 0x11, A
    GOTO loop_start


; ======================================================
; ???
; ======================================================
loop_start:
    ; if (n > m) ? break
    MOVF 0x04, W, A
    CPFSGT 0x02, A
    BRA high_equal_check
    GOTO end_loop

high_equal_check:
    MOVF 0x04, W, A
    CPFSEQ 0x02, A
    GOTO loop_continue
    MOVF 0x03, W, A
    CPFSGT 0x01, A
    GOTO loop_continue
    GOTO end_loop

; ======================================================
; ???????? GOTO ???
; ======================================================
loop_continue:
    MOVFF 0x01, 0x20
    MOVFF 0x02, 0x21
    GOTO is_prime_entry

is_prime_return:
    MOVF 0x12, W, A
    BZ skip_inc
    INCF 0x10, F, A
    BTFSC STATUS, Z, A
    INCF 0x11, F, A

skip_inc:
    INCF 0x01, F, A
    BTFSC STATUS, Z, A
    INCF 0x02, F, A
    GOTO loop_start


; ======================================================
; ???????????
; ======================================================
end_loop:
    MOVF 0x10, W, A
    MOVWF 0x001
    MOVF 0x11, W, A
    MOVWF 0x002
    GOTO end_program


; ======================================================
; is_prime?? GOTO ?????
; ======================================================
is_prime_entry:
    MOVF 0x21, W, A
    BNZ prime_check
    MOVLW 0x02
    CPFSLT 0x20, A
    GOTO prime_check
    MOVLW 0x00
    MOVWF 0x12, A
    GOTO is_prime_return
check_even:
    BTFSS 0x20 , 0
    GOTO maybe_even 
    GOTO prime_check
maybe_even:
    MOVLW 0x02
    CPFSEQ 0x20 
    GOTO not_prime
    MOVF 0x21 ,W
    BNZ not_prime
    GOTO prime_check

prime_check:
    MOVLW 0x02
    MOVWF 0x22, A
    CLRF 0x23, A
    GOTO check_loop

check_loop:
    MOVF 0x22, W, A
    XORWF 0x20, W, A
    BNZ skip_equal
    MOVF 0x23, W, A
    XORWF 0x21, W, A
    BZ no_factor_found
skip_equal:
    MOVFF 0x20, 0x30
    MOVFF 0x21, 0x31
    MOVFF 0x22, 0x32
    MOVFF 0x23, 0x33
    GOTO mod16_entry

mod16_return:
    MOVF 0x34, W, A
    IORWF 0x35, W, A
    BZ not_prime
    INCF 0x22, F, A
    BTFSC STATUS, Z, A
    INCF 0x23, F, A
    GOTO check_loop

no_factor_found:
    MOVLW 0x01
    MOVWF 0x12, A
    GOTO is_prime_return

not_prime:
    MOVLW 0x00
    MOVWF 0x12, A
    GOTO is_prime_return


; ======================================================
; mod16 (? GOTO)
; ======================================================
mod16_entry:
mod_loop:
    MOVF 0x33, W, A
    SUBWF 0x31, W, A
    BNZ mod_low
    MOVF 0x32, W, A
    SUBWF 0x30, W, A
mod_low:
    BNC mod_done
    MOVF 0x32, W, A
    SUBWF 0x30, F, A
    MOVF 0x33, W, A
    SUBWFB 0x31, F, A
    GOTO mod_loop
mod_done:
    MOVFF 0x30, 0x34
    MOVFF 0x31, 0x35
    GOTO mod16_return


; ======================================================
; ????
; ======================================================
end_program:
    NOP
    RETURN
    END
