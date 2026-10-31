/**
 * ============================================================================
 * SentinelSoC — Authoritative Memory Map & Register Offsets
 * File: firmware/sentinelsoc_memory_map.h
 * Target: RISC-V RV32IM / VeeR EL2
 * ============================================================================
 */

#ifndef SENTINELSOC_MEMORY_MAP_H
#define SENTINELSOC_MEMORY_MAP_H

#include <stdint.h>

#define REG32(addr) (*(volatile uint32_t *)((uintptr_t)(addr)))
#define REG16(addr) (*(volatile uint16_t *)((uintptr_t)(addr)))
#define REG8(addr)  (*(volatile uint8_t *)((uintptr_t)(addr)))

/* ----------------------------------------------------------------------------
 * Memory Regions
 * ---------------------------------------------------------------------------- */
#define IMEM_BASE         0x00000000UL /* 64 KB Instruction Memory */
#define DMEM_BASE         0x00010000UL /* 64 KB Data Memory */

/* ----------------------------------------------------------------------------
 * Authoritative Peripheral Apertures (4 KB each)
 * ---------------------------------------------------------------------------- */
#define UART_BASE         0x10000000UL /* M00: UART Controller */
#define TIMER_BASE        0x10001000UL /* M01: Hardware Timer/Counter */
#define GPIO_BASE         0x10002000UL /* M02: General Purpose I/O */
#define ADC_BASE          0x10003000UL /* M03: 12-bit SAR ADC Controller */
#define FIR_BASE          0x10004000UL /* M04: 16-tap FIR Filter Engine */
#define QRS_BASE          0x10005000UL /* M05: QRS R-Peak Detector */
#define AES_BASE          0x10006000UL /* M06: AES-128 Encryption Engine */
#define WDT_BASE          0x10007000UL /* M07: Watchdog Timer */
#define INTC_BASE         0x10008000UL /* M08: Interrupt Aggregator */

/* ----------------------------------------------------------------------------
 * 1. UART Registers
 * ---------------------------------------------------------------------------- */
#define UART_REG_RBR      (UART_BASE + 0x00) /* RX Buffer (RO) */
#define UART_REG_THR      (UART_BASE + 0x00) /* TX Holding (WO) */
#define UART_REG_IER      (UART_BASE + 0x04) /* Interrupt Enable */
#define UART_REG_IIR      (UART_BASE + 0x08) /* Interrupt Identification (RO) */
#define UART_REG_FCR      (UART_BASE + 0x08) /* FIFO Control (WO) */
#define UART_REG_LCR      (UART_BASE + 0x0C) /* Line Control */
#define UART_REG_LSR      (UART_BASE + 0x14) /* Line Status */

/* ----------------------------------------------------------------------------
 * 2. Timer Registers
 * ---------------------------------------------------------------------------- */
#define TIMER_REG_CTRL    (TIMER_BASE + 0x00)
#define TIMER_REG_PRESC   (TIMER_BASE + 0x04)
#define TIMER_REG_COMPARE (TIMER_BASE + 0x08)
#define TIMER_REG_COUNTER (TIMER_BASE + 0x0C)
#define TIMER_REG_STATUS  (TIMER_BASE + 0x10)

/* ----------------------------------------------------------------------------
 * 3. GPIO Registers
 * ---------------------------------------------------------------------------- */
#define GPIO_REG_DIR      (GPIO_BASE + 0x00) /* Direction: 1=out, 0=in */
#define GPIO_REG_DATA     (GPIO_BASE + 0x04) /* Output Data */
#define GPIO_REG_INPUT    (GPIO_BASE + 0x08) /* Input Live Pins */
#define GPIO_REG_IMASK    (GPIO_BASE + 0x0C) /* Interrupt Mask */
#define GPIO_REG_STATUS   (GPIO_BASE + 0x10) /* Status (W1C) */

/* ----------------------------------------------------------------------------
 * 4. ADC Registers
 * ---------------------------------------------------------------------------- */
#define ADC_REG_CTRL      (ADC_BASE + 0x00)
#define ADC_REG_STATUS    (ADC_BASE + 0x04)
#define ADC_REG_DATA      (ADC_BASE + 0x08)
#define ADC_REG_DIV       (ADC_BASE + 0x0C)

/* ----------------------------------------------------------------------------
 * 5. FIR Filter Registers
 * ---------------------------------------------------------------------------- */
#define FIR_REG_CTRL      (FIR_BASE + 0x00)
#define FIR_REG_COEFF(i)  (FIR_BASE + 0x04 + ((i) * 4))
#define FIR_REG_DATA_OUT  (FIR_BASE + 0x44)
#define FIR_REG_STATUS    (FIR_BASE + 0x48)

/* ----------------------------------------------------------------------------
 * 6. QRS Detector Registers
 * ---------------------------------------------------------------------------- */
#define QRS_REG_CTRL      (QRS_BASE + 0x00)
#define QRS_REG_THRESH_HI (QRS_BASE + 0x04)
#define QRS_REG_RR        (QRS_BASE + 0x08)
#define QRS_REG_BPM       (QRS_BASE + 0x0C)
#define QRS_REG_STATUS    (QRS_BASE + 0x10)

/* ----------------------------------------------------------------------------
 * 7. AES-128 Registers
 * ---------------------------------------------------------------------------- */
#define AES_REG_CSR       (AES_BASE + 0x00) /* [0]=START, [31]=DONE */
#define AES_REG_KEY0      (AES_BASE + 0x04)
#define AES_REG_KEY1      (AES_BASE + 0x08)
#define AES_REG_KEY2      (AES_BASE + 0x0C)
#define AES_REG_KEY3      (AES_BASE + 0x10)
#define AES_REG_TIN0      (AES_BASE + 0x14)
#define AES_REG_TIN1      (AES_BASE + 0x18)
#define AES_REG_TIN2      (AES_BASE + 0x1C)
#define AES_REG_TIN3      (AES_BASE + 0x20)
#define AES_REG_TOUT0     (AES_BASE + 0x24)
#define AES_REG_TOUT1     (AES_BASE + 0x28)
#define AES_REG_TOUT2     (AES_BASE + 0x2C)
#define AES_REG_TOUT3     (AES_BASE + 0x30)

/* ----------------------------------------------------------------------------
 * 8. Watchdog Timer (WDT) Registers
 * ---------------------------------------------------------------------------- */
#define WDT_REG_CTRL      (WDT_BASE + 0x00) /* [0]=EN, [1]=IE, [2]=RESET_EN */
#define WDT_REG_RELOAD    (WDT_BASE + 0x04)
#define WDT_REG_COUNT     (WDT_BASE + 0x08)
#define WDT_REG_FEED      (WDT_BASE + 0x0C)
#define WDT_REG_STATUS    (WDT_BASE + 0x10)

/* ----------------------------------------------------------------------------
 * 9. Interrupt Aggregator Registers
 * ---------------------------------------------------------------------------- */
#define INTC_REG_CAUSE    (INTC_BASE + 0x00) /* [6:0] cause bits (W1C) */
#define INTC_REG_MASK     (INTC_BASE + 0x04) /* [6:0] enable mask */

/* Firmware Mailbox at DMEM top for Simulation Verification */
#define MAILBOX_TEST_ID   (DMEM_BASE + 0x0FF0)
#define MAILBOX_STATUS    (DMEM_BASE + 0x0FF4)
#define MAILBOX_VALUE     (DMEM_BASE + 0x0FF8)
#define MAILBOX_MAGIC     (DMEM_BASE + 0x0FFC)

#endif /* SENTINELSOC_MEMORY_MAP_H */
