# SentinelSoC Authoritative Memory Map & Port Allocation

| Interconnect Port | Subsystem / IP Block | Base Address | End Address | Aperture Size | Protocol / Wrapper |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **S00** | RISC-V RV32 CPU (LSU) | — (Initiator) | — | — | Full AXI4 Master |
| **S01** | Inactive Master Placeholder | — | — | — | Tied off |
| **S02** | Inactive Master Placeholder | — | — | — | Tied off |
| **M00** | UART Controller | `0x1000_0000` | `0x1000_0FFF` | 4 KB | Native AXI4 Slave |
| **M01** | Hardware Timer / Counter | `0x1000_1000` | `0x1000_1FFF` | 4 KB | AXI4-to-AXI4Lite Bridge |
| **M02** | GPIO Subsystem (8-bit) | `0x1000_2000` | `0x1000_2FFF` | 4 KB | AXI4-to-AXI4Lite Bridge |
| **M03** | 12-Bit SAR ADC Interface | `0x1000_3000` | `0x1000_3FFF` | 4 KB | Native AXI4-Lite Slave |
| **M04** | 16-Tap FIR Filter Engine | `0x1000_4000` | `0x1000_4FFF` | 4 KB | AXI4-Lite Subset |
| **M05** | QRS Detection Accelerator | `0x1000_5000` | `0x1000_5FFF` | 4 KB | Native AXI4 Slave |
| **M06** | AES-128 Encryption Engine | `0x1000_6000` | `0x1000_6FFF` | 4 KB | AXI4-to-AXI4Lite Bridge |
| **M07** | Watchdog Timer (WDT) | `0x1000_7000` | `0x1000_7FFF` | 4 KB | AXI4-to-AXI4Lite Bridge |
| **M08** | Interrupt Aggregator | `0x1000_8000` | `0x1000_8FFF` | 4 KB | AXI4-to-AXI4Lite Bridge |
| **M09** | Instruction Memory (IMEM) | `0x0000_0000` | `0x0000_FFFF` | 64 KB | Native AXI4 SRAM Slave |
| **M10** | Data Memory (DMEM) | `0x0001_0000` | `0x0001_FFFF` | 64 KB | Native AXI4 SRAM Slave |

---

### Interrupt Mapping (Interrupt Aggregator: 0x1000_8000)

| Bit | Source Name | Trigger Condition | Clear Mechanism |
| :---: | :--- | :--- | :--- |
| `0` | `uart_irq` | RX buffer full / byte received | Read `UART_RBR` or W1C |
| `1` | `timer_irq` | Counter reached COMPARE reload value | W1C `TIMER_STATUS` |
| `2` | `gpio_irq` | Pin edge event enabled by `IRQ_MASK` | W1C `GPIO_STATUS` |
| `3` | `adc_irq` | Conversion complete / sample available | Read sample / W1C |
| `4` | `qrs_peak_irq`| R-peak detection pulse asserted | Self-clearing pulse / W1C |
| `5` | `aes_done_irq` | 128-bit AES block encryption finished | W1C `AES_CSR` |
| `6` | `wdt_irq` | Watchdog counter reached 25% threshold | Feed watchdog or W1C |
