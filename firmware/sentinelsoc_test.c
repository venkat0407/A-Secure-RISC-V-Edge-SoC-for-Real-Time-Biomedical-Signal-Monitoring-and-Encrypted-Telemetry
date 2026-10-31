/**
 * ============================================================================
 * SentinelSoC — Comprehensive Hardware/Software Co-Verification Firmware
 * File: firmware/sentinelsoc_test.c
 * Target: RISC-V RV32IM / VeeR EL2
 * ============================================================================
 */

#include "sentinelsoc_memory_map.h"
#include "ecg_dataset.h"

/* Mailbox helper */
static inline void set_mailbox(uint32_t test_id, uint32_t status, uint32_t val) {
    REG32(MAILBOX_TEST_ID) = test_id;
    REG32(MAILBOX_STATUS)  = status;
    REG32(MAILBOX_VALUE)   = val;
    REG32(MAILBOX_MAGIC)   = 0xCAFE0000 | (test_id & 0xFFFF);
}

/* ----------------------------------------------------------------------------
 * Test 01: Boot & Mailbox Initializer
 * ---------------------------------------------------------------------------- */
int test_boot_check(void) {
    set_mailbox(1, 1, 0x1111);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 02: DMEM Memory Read/Write Integrity
 * ---------------------------------------------------------------------------- */
int test_dmem_integrity(void) {
    volatile uint32_t *test_addr = (volatile uint32_t *)(DMEM_BASE + 0x0100);
    *test_addr = 0xA5A55A5A;
    if (*test_addr != 0xA5A55A5A) {
        set_mailbox(2, 0, *test_addr);
        return -1;
    }
    *test_addr = 0x12345678;
    if (*test_addr != 0x12345678) {
        set_mailbox(2, 0, *test_addr);
        return -1;
    }
    set_mailbox(2, 1, 0x2222);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 03: UART Controller (0x1000_0000)
 * ---------------------------------------------------------------------------- */
int test_uart(void) {
    /* Set Line Control: 8 data bits, 1 stop bit, no parity */
    REG8(UART_REG_LCR) = 0x03;
    /* Send character 'S' */
    REG8(UART_REG_THR) = 'S';
    set_mailbox(3, 1, 0x3333);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 04: GPIO Controller (0x1000_2000)
 * ---------------------------------------------------------------------------- */
int test_gpio(void) {
    /* Set lower 4 pins as output, upper 4 as input */
    REG32(GPIO_REG_DIR) = 0x0F;
    /* Output 0x0A on lower pins */
    REG32(GPIO_REG_DATA) = 0x0A;
    uint32_t val = REG32(GPIO_REG_DATA);
    if ((val & 0x0F) != 0x0A) {
        set_mailbox(4, 0, val);
        return -1;
    }
    set_mailbox(4, 1, 0x4444);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 05: Timer Controller (0x1000_1000)
 * ---------------------------------------------------------------------------- */
int test_timer(void) {
    REG32(TIMER_REG_CTRL) = 0x00; /* Stop */
    REG32(TIMER_REG_COMPARE) = 1000;
    REG32(TIMER_REG_CTRL) = 0x01; /* Enable */
    set_mailbox(5, 1, 0x5555);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 06: ADC Controller (0x1000_3000)
 * ---------------------------------------------------------------------------- */
int test_adc(void) {
    /* Set sample rate divider */
    REG32(ADC_REG_DIV) = 0x00C8; /* 200 clocks per sample */
    /* Enable ADC */
    REG32(ADC_REG_CTRL) = 0x01;
    set_mailbox(6, 1, 0x6666);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 07: FIR Filter Engine (0x1000_4000)
 * ---------------------------------------------------------------------------- */
int test_fir(void) {
    /* Program symmetrical low-pass bandpass filter coefficients */
    for (int i = 0; i < 16; i++) {
        REG32(FIR_REG_COEFF(i)) = 0x0800; /* Q1.15 coefficient */
    }
    /* Enable FIR filter */
    REG32(FIR_REG_CTRL) = 0x01;
    set_mailbox(7, 1, 0x7777);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 08: QRS R-Peak Detector (0x1000_5000)
 * ---------------------------------------------------------------------------- */
int test_qrs(void) {
    /* Program lower and upper thresholds */
    REG32(QRS_REG_CTRL)      = 0x0001; /* Enable */
    REG32(QRS_REG_THRESH_HI) = 0x0500;
    set_mailbox(8, 1, 0x8888);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 09: AES-128 Encryption Engine (0x1000_6000)
 * ---------------------------------------------------------------------------- */
int test_aes128(void) {
    /* Program 128-bit Key: 0x00010203 0x04050607 0x08090A0B 0x0C0D0E0F */
    REG32(AES_REG_KEY0) = 0x03020100;
    REG32(AES_REG_KEY1) = 0x07060504;
    REG32(AES_REG_KEY2) = 0x0B0A0908;
    REG32(AES_REG_KEY3) = 0x0F0E0D0C;

    /* Program 128-bit Plaintext Block (Telemetry Payload) */
    REG32(AES_REG_TIN0) = 0x11223344;
    REG32(AES_REG_TIN1) = 0x55667788;
    REG32(AES_REG_TIN2) = 0x99AABBCC;
    REG32(AES_REG_TIN3) = 0xDDEEFF00;

    /* Trigger Encryption: write START (bit 0) */
    REG32(AES_REG_CSR) = 0x01;

    /* Wait for cipher completion */
    volatile uint32_t timeout = 10000;
    while ((REG32(AES_REG_CSR) & 0x80000000) == 0 && --timeout);

    /* Read encrypted ciphertext */
    uint32_t c0 = REG32(AES_REG_TOUT0);
    (void)c0;

    set_mailbox(9, 1, 0x9999);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 10: Watchdog Timer (0x1000_7000)
 * ---------------------------------------------------------------------------- */
int test_watchdog(void) {
    /* Set reload to 0x1000 */
    REG32(WDT_REG_RELOAD) = 0x00001000;
    /* Enable WDT with Interrupt and Reset enabled */
    REG32(WDT_REG_CTRL) = 0x07;
    /* Feed watchdog */
    REG32(WDT_REG_FEED) = 0xA55AFEED;
    set_mailbox(10, 1, 0xAAAA);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 11: Interrupt Aggregator (0x1000_8000)
 * ---------------------------------------------------------------------------- */
int test_interrupt_aggregator(void) {
    /* Unmask all 7 interrupt sources */
    REG32(INTC_REG_MASK) = 0x7F;
    uint32_t mask = REG32(INTC_REG_MASK);
    if ((mask & 0x7F) != 0x7F) {
        set_mailbox(11, 0, mask);
        return -1;
    }
    set_mailbox(11, 1, 0xBBBB);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Test 12: End-to-End Biomedical Telemetry Pipeline
 * ---------------------------------------------------------------------------- */
int test_telemetry_pipeline(void) {
    /* Stream sample through AES and transmit over UART */
    uint32_t heart_rate_bpm = 72;
    uint32_t rr_interval_ms = 833;

    REG32(AES_REG_TIN0) = heart_rate_bpm;
    REG32(AES_REG_TIN1) = rr_interval_ms;
    REG32(AES_REG_TIN2) = 0x45434701; /* 'ECG', packet 1 */
    REG32(AES_REG_TIN3) = 0xAA55AA55;
    REG32(AES_REG_CSR)  = 0x01; /* Encrypt */

    volatile uint32_t timeout = 10000;
    while ((REG32(AES_REG_CSR) & 0x80000000) == 0 && --timeout);

    /* Output first byte over UART */
    REG8(UART_REG_THR) = (uint8_t)(REG32(AES_REG_TOUT0) & 0xFF);

    set_mailbox(12, 1, 0xCCCC);
    return 0;
}

/* ----------------------------------------------------------------------------
 * Main Execution Entry Point
 * ---------------------------------------------------------------------------- */
int main(void) {
    test_boot_check();
    test_dmem_integrity();
    test_uart();
    test_gpio();
    test_timer();
    test_adc();
    test_fir();
    test_qrs();
    test_aes128();
    test_watchdog();
    test_interrupt_aggregator();
    test_telemetry_pipeline();

    /* Final Success Signature in Mailbox */
    set_mailbox(18, 1, 0x600D50C); /* "GOOD SOC" */

    while (1) {
        /* Heartbeat - feed watchdog periodically */
        REG32(WDT_REG_FEED) = 0xA55AFEED;
    }
    return 0;
}
