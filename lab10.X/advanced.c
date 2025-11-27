#include <xc.h>
#include <pic18f4520.h>
#include "test_uart.h"

#define _XTAL_FREQ 4000000


volatile unsigned char counter = 0;        // 0x00 ~ 0x0F
volatile unsigned int  ms_accum = 0;       // millisecond accumulator
volatile unsigned int  delay_ms = 1000;    // current LED update interval (ms)
volatile unsigned char tick = 0;           // set by Timer2 ISR when time up

#define UART_BUF_SIZE 8
volatile char uart_buf[UART_BUF_SIZE];
volatile unsigned char uart_idx = 0;
volatile unsigned char uart_line_ready = 0;

void LED_update(unsigned char val) {
    LATDbits.LATD4 = (val >> 0) & 1;
    LATDbits.LATD5 = (val >> 1) & 1;
    LATDbits.LATD6 = (val >> 2) & 1;
    LATDbits.LATD7 = (val >> 3) & 1;
}

static inline void UART_putc(char c) {
    test_uart_write((unsigned char)c);
}

void UART_puts(const char *s) {
    while (*s) {
        UART_putc(*s++);
    }
}

void timer2_init_1ms(void) {
    /*
        Fosc = 4MHz ? Fcy = Fosc/4 = 1MHz ? 1us / tick
        Prescaler = 16 ? 16us / tick
        PR2 = 62 ? (62+1)*16us ? 1008us ? 1.0ms
    */
    T2CONbits.T2CKPS = 0b11;   // Prescaler = 16
    PR2 = 62;                  // ~1ms period
    T2CONbits.T2OUTPS = 0;     // Postscaler = 1:1

    PIR1bits.TMR2IF = 0;       // clear flag
    PIE1bits.TMR2IE = 1;       // enable Timer2 interrupt
    IPR1bits.TMR2IP = 0;       // LOW priority

    T2CONbits.TMR2ON = 1;      // start Timer2
}

// ====== parse uart_buf : "0.1" ~ "0.9" or "1.0" ======
void apply_new_delay_from_buffer(void) {
    unsigned int new_delay = delay_ms;   // default = no change

    // format: "0.x"
    if (uart_buf[0] == '0' && uart_buf[1] == '.' &&
        (uart_buf[2] >= '1' && uart_buf[2] <= '9') &&
        (uart_buf[3] == '\0')) 
    {
        unsigned char d = uart_buf[2] - '0';   // 1 ~ 9
        new_delay = (unsigned int)d * 100;     // 0.1s~0.9s ? 100~900 ms
    }
    // format: "1.0"
    else if (uart_buf[0] == '1' && uart_buf[1] == '.' &&
             uart_buf[2] == '0' && uart_buf[3] == '\0')
    {
        new_delay = 1000;                     // 1.0s
    }
    else {
        // invalid input, ignore
        return;
    }

    delay_ms = new_delay;    // apply immediately
}

// ====== High priority ISR : UART RX ======
void __interrupt(high_priority) high_isr(void) {
    // UART RX interrupt
    if (PIE1bits.RCIE && PIR1bits.RCIF) {
        char c = RCREG;  // must read to clear RCIF

        // handle overrun error
        if (RCSTAbits.OERR) {
            RCSTAbits.CREN = 0;
            RCSTAbits.CREN = 1;
        }

        // echo back (optional,??debug)
        test_uart_write((unsigned char)c);

        if (c == '\r' || c == '\n') {   // Enter: line complete
            uart_buf[uart_idx] = '\0';
            uart_line_ready = 1;
            uart_idx = 0;
        } else {
            if (uart_idx < UART_BUF_SIZE - 1) {
                uart_buf[uart_idx++] = c;
            }
        }
    }
}

// ====== Low priority ISR : Timer2 ======
void __interrupt(low_priority) low_isr(void) {
    if (PIE1bits.TMR2IE && PIR1bits.TMR2IF) {
        PIR1bits.TMR2IF = 0;
        ms_accum++;

        if (ms_accum >= delay_ms) {
            ms_accum = 0;
            tick = 1;              // notify main loop to update counter
        }
    }
}

// ===================== main =====================
void main(void) {
    // I/O
    TRISD = 0x00;
    LATD  = 0x00;

    // enable interrupt priority
    RCONbits.IPEN = 1;

    // UART init (from TA lib)
    test_uart_init();

    // UART RX interrupt: high priority
    PIE1bits.RCIE = 1;
    IPR1bits.RCIP = 1;

    // Timer2 init: low priority
    timer2_init_1ms();

    // global interrupts
    INTCONbits.GIEH = 1;   // high-priority enable
    INTCONbits.GIEL = 1;   // low-priority enable

    // Initial display
    counter = 0;
    LED_update(counter);


    while (1) {
        // === Timer2 tick: update counter & LED ===
        if (tick) {
            tick = 0;

            counter = (counter + 1) & 0x0F;   // 0x00~0x0F cyclic
            LED_update(counter);
        }

        // === UART command ready: parse new delay ===
        if (uart_line_ready) {
            uart_line_ready = 0;
            apply_new_delay_from_buffer();
            // (optionally ???? delay)
            UART_puts("\r\nNew delay set.\r\n");
        }
    }
}
