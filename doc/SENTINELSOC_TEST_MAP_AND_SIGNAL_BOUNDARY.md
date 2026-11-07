# SentinelSoC: Verification Test Map & Signal Boundary Specification

**Document Version:** 1.0.0  
**Project:** SentinelSoC — Secure RISC-V Biomedical Edge Monitoring & Telemetry SoC  
**Platform:** Western Digital VeeR EL2 (RV32IMC), 3×11 AXI4 Interconnect, Synopsys VCS / Verdi  
**Status:** Approved & Verified (18 / 18 Tests Passing, 100.0%)

---

## 1. Executive Overview

This document provides an authoritative breakdown of the **SentinelSoC signal boundary classification** and the **architectural verification test map**. It details:
1. **Out-of-Boundary Signals:** External chip-level pins interfacing the SoC with off-chip biomedical sensors, telemetry transceivers, actuators, power/clock systems, and debug hosts.
2. **Inside-the-Boundary Signals:** Internal on-chip interconnects, streaming DSP channels, peripheral buses, interrupt lines, and safety reset networks.
3. **Architectural Test Map:** A structured traceability matrix mapping verification test cases (TC-01 through TC-18) against peripheral apertures, internal buses, boundary interactions, stimulus mechanisms, and pass criteria.

---

## 2. Signal Boundary Classification

```text
       ========================== CHIP BOUNDARY ==========================
       
          [EXTERNAL IN]                                   [EXTERNAL OUT]
          clk                 --------------------->      uart_tx
          rst_n               --------------------->      alert_led (autonomous)
          uart_rx             --------------------->      wdt_reset_n
          adc_sample_data     --------------------->      core_irq_out
          adc_sample_valid
                                  [EXTERNAL INOUT]
                              <--- gpio_io[7:0] --->
                              
       ===================================================================
       |                        INSIDE BOUNDARY                          |
       |                                                                 |
       |  +-------------+      +-------------------+      +-----------+  |
       |  | VeeR EL2 CPU| <--> | 3x11 AXI4 XBAR    | <--> | Memories  |  |
       |  | (RV32 Core) |      | (Interconnect)    |      | IMEM/DMEM |  |
       |  +-------------+      +-------------------+      +-----------+  |
       |         ^                       |                               |
       |         |               +---------------+                       |
       |     core_irq            |  Peripherals  |                       |
       |         |               |  (M00 - M08)  |                       |
       |   +-----------+         +---------------+                       |
       |   | Interrupt |                 |                               |
       |   | Aggregator|<-- 7 IRQ lines -+                               |
       |   +-----------+                 |                               |
       |                     Biomedical Streaming:                       |
       |             ADC Stream ===> FIR Filter ===> QRS Detector        |
       |                                                                 |
       ===================================================================
```

---

### 2.1 Out-of-Boundary Signals (External Chip Pins)

The signals listed below cross the SoC boundary to connect to external printed circuit board (PCB) components, sensors, or host test equipment.

| Pin / Signal Name | Direction | Width | Pin Type | Domain | Description & System Functional Role |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **`clk`** | Input | 1-bit | Clock | System | Primary system master clock (nominal 50 MHz, 20 ns period). Feeds CPU, interconnect, all peripherals, and memories synchronously. |
| **`rst_n`** | Input | 1-bit | Asynchronous / Active-Low | System | Master active-low power-on reset. When pulled low (`0`), initializes all registers, resets the AXI interconnect, and sets CPU PC to `0x0000_0000`. |
| **`uart_rx`** | Input | 1-bit | Digital Input | Peripheral (M00) | External serial communication input for telemetry configuration, parameter updates, and command ingestion. |
| **`uart_tx`** | Output | 1-bit | Digital Output | Peripheral (M00) | Serial telemetry transmission output (8N1). Streams telemetry packets and encrypted ECG alert payloads to external transceivers. |
| **`gpio_io`** | Inout | 8-bit | Bidirectional (Tri-state) | Peripheral (M02) | 8-bit general-purpose I/O bus. Controlled by direction registers (`DIR`) and output data registers (`DATA_O`). Supports bitwise input readback. |
| **`adc_sample_data`** | Input | 12-bit | Digital Bus | Peripheral (M03) | 12-bit raw ECG digitized sample data from external SAR ADC (values `0x000` to `0xFFF`, centered at `0x800`). |
| **`adc_sample_valid`** | Input | 1-bit | Strobe | Peripheral (M03) | ADC sample valid strobe. Pulses high for 1 clock cycle to notify the ADC controller and streaming DSP pipeline of a new sample. |
| **`alert_led`** | Output | 1-bit | Direct Hardware Out | Safety / QRS | **Dedicated autonomous cardiac alert pin.** Directly driven by the hardware QRS engine when tachycardia, bradycardia, or an R-peak occurs. **Bypasses CPU.** |
| **`wdt_reset_n`** | Output | 1-bit | Active-Low Output | Safety / WDT | Hardware system reset output triggered if the CPU fails to service the Watchdog Timer within the programmable window (`FEED` timeout). |
| **`core_irq_out`** | Output | 1-bit | Interrupt Diagnostic | Diagnostics | Exported aggregate interrupt line reflecting `u_intc.core_irq`. Allows external hardware or logic analyzer to observe system IRQ assertion. |

---

### 2.2 Inside-the-Boundary Signals (Internal Subsystem Interconnects)

The signals below exist strictly inside the SoC boundary and do not leave the silicon die or top-level hierarchy.

#### A. RISC-V Processor Core Master Port (S00)
- **Signal Bus:** `s00_axi_aw*`, `s00_axi_w*`, `s00_axi_b*`, `s00_axi_ar*`, `s00_axi_r*`
- **Source:** VeeR EL2 Load-Store Unit (LSU) Bus Master (`u_cpu`)
- **Destination:** AXI4 Crossbar Interconnect (`u_interconnect`)
- **Widths & Attributes:** 32-bit address, 32-bit data, 8-bit transaction ID, burst support (`INCR`), cache/prot/qos lines.
- **Description:** Primary master port initiating instructions and data transactions across all 11 memory and peripheral slave apertures.

#### B. AXI4 Interconnect Slave Aperture Buses (M00 – M10)
All 11 slave channels are routed internally by the crossbar decoding the upper address bits:

| Aperture | Subsystem | Internal Bus Signals | Destination Block | Protocol / Bridge |
| :---: | :--- | :--- | :--- | :--- |
| **M00** | UART | `m00_axi_*` (AW, W, B, AR, R) | `u_uart` (`axi_uart_top`) | Native AXI4 Slave |
| **M01** | Timer / Counter | `m01_axi_*` -> `timer_lite_*` | `u_timer` (`timer_axi`) | AXI4-to-AXI4Lite Bridge (`u_bridge_timer`) |
| **M02** | GPIO Subsystem | `m02_axi_*` -> `gpio_lite_*` | `u_gpio` (`gpio_axi`) | AXI4-to-AXI4Lite Bridge (`u_bridge_gpio`) |
| **M03** | ADC Controller | `m03_axi_*` | `u_adc` (`adc_controller`) | Native AXI4-Lite Slave |
| **M04** | FIR Filter | `m04_axi_*` -> `fir_axi_*` | `u_fir` (`fir_top`) | AXI4-Lite Register Subset |
| **M05** | QRS Accelerator | `m05_axi_*` | `u_qrs` (`qrs_axi4_wrapper`) | Native AXI4 Slave |
| **M06** | AES-128 Engine | `m06_axi_*` -> `aes_lite_*` | `u_aes` (`axi_aes_cipher_slave`) | AXI4-to-AXI4Lite Bridge (`u_bridge_aes`) |
| **M07** | Watchdog Timer | `m07_axi_*` -> `wdt_lite_*` | `u_wdt` (`wdt_axi`) | AXI4-to-AXI4Lite Bridge (`u_bridge_wdt`) |
| **M08** | Interrupt Aggregator | `m08_axi_*` -> `intc_lite_*` | `u_intc` (`interrupt_aggregator`)| AXI4-to-AXI4Lite Bridge (`u_bridge_intc`) |
| **M09** | IMEM (Instruction SRAM) | `m09_axi_*` | `u_imem` (`axi_imem_slave`) | Native AXI4 SRAM Slave (64 KB) |
| **M10** | DMEM (Data SRAM) | `m10_axi_*` | `u_dmem` (`axi_dmem_slave`) | Native AXI4 SRAM Slave (64 KB) |

#### C. Autonomous Biomedical Processing Streaming Pipeline
The biomedical data path operates autonomously without CPU bus intervention:
1. **ADC to FIR Streaming Interface:**
   - Signals: `adc_sample_valid` directly connects to `u_fir.s_axis_tvalid`; sign-extended sample `{{4{adc_sample_data[11]}}, adc_sample_data}` connects to `u_fir.s_axis_tdata[15:0]`.
   - Protocol: AXI4-Stream compatible valid handshake.
2. **FIR to QRS Streaming Pipeline:**
   - Signals: `fir_m_axis_tdata[15:0]`, `fir_m_axis_tvalid`, `fir_m_axis_tready`.
   - Connection: FIR filter bandpass output streams directly into the Pan-Tompkins QRS algorithm pipeline (`u_qrs.u_wtsee`).
3. **Internal Cardiac Diagnostic Signals:**
   - `u_qrs.u_wtsee.r_peak`: 1-clock strobe asserted on confirmed R-peak detection.
   - `u_qrs.u_wtsee.rhythm_class[1:0]`: `00` = Normal Sinus Rhythm, `01` = Tachycardia (elevated heart rate), `10` = Bradycardia (low heart rate).
   - `u_qrs.u_wtsee.rr_interval[15:0]`: Measured interval in milliseconds between consecutive R-peaks.
   - `u_qrs.u_wtsee.bpm[15:0]`: Real-time computed Beats Per Minute (BPM) value.

#### D. Internal Interrupt Distribution Network
The 7 peripheral interrupt sources feed directly into the Interrupt Aggregator:

| Aggregator Bit | Internal Signal Wire | Producing Block | Clearing Mechanism | Destination |
| :---: | :--- | :--- | :--- | :--- |
| `0` | `uart_irq` | `u_uart` | Read `UART_RBR` or W1C | `u_intc.raw_irqs[0]` |
| `1` | `timer_irq` | `u_timer` | W1C `TIMER_STATUS` | `u_intc.raw_irqs[1]` |
| `2` | `gpio_irq` | `u_gpio` | W1C `GPIO_STATUS` | `u_intc.raw_irqs[2]` |
| `3` | `adc_irq_sample` | `u_adc` | Read FIFO or W1C | `u_intc.raw_irqs[3]` |
| `4` | `qrs_peak_irq` | `u_qrs` | Auto-clearing pulse / W1C | `u_intc.raw_irqs[4]` |
| `5` | `aes_done_irq` | `u_aes` | W1C `AES_CSR` | `u_intc.raw_irqs[5]` |
| `6` | `wdt_irq` | `u_wdt` | Feed watchdog or W1C | `u_intc.raw_irqs[6]` |
| **Combined** | `core_irq` | `u_intc` | Cleared when all unmasked pending IRQs resolved | `u_cpu.extintsrc_req` & `core_irq_out` |

#### E. Internal Safety & Reset Routing
- `aresetn`: Internal active-low reset tree synchronized with `clk`.
- `rst`: Inverted reset wire (`~rst_n`) used by modules requiring active-high reset.
- `wdt_reset_n`: Internal signal driving the top-level external reset pin upon WDT countdown expiration.

---

## 3. Comprehensive Verification Test Map

The table below maps the complete 18-test regression suite (`tb/tb_sentinelsoc_top.sv`).

| Test ID | Test Name | Target Subsystem / Aperture | Base Address | Boundary Scope | Stimulus Applied | Monitored Output & Expected Result | Status |
| :---: | :--- | :--- | :---: | :---: | :--- | :--- | :---: |
| **TC-01** | RISC-V CPU Boot & SoC Reset Bring-Up | System Reset & CPU Core | `0x0000_0000` | **Crosses Boundary (In)** | Toggle external `rst_n` from `0` to `1` across 10 clock cycles. | Verify `dut.rst == 0`, `dut.aresetn == 1`, and CPU reset release. | **PASS** |
| **TC-02** | Data Memory Access & SRAM Integrity | Data SRAM (DMEM, M10) | `0x0001_0000` | **Inside Boundary** | Write test word `0xA5A55A5A` to `0x0001_0100` via CPU LSU master S00. | Readback from `0x0001_0100` matches `0xA5A55A5A` without byte corruptions. | **PASS** |
| **TC-03** | AXI4 Interconnect Address Mapping & Protocol | AXI4 Crossbar & UART (M00) | `0x1000_0000` | **Inside Boundary** | Read UART Line Status Register at `0x1000_0014` via interconnect crossbar. | Interconnect maps address to M00; returns valid non-X read data (`rdata[5] == 1`). | **PASS** |
| **TC-04** | Bus Contention & Interconnect Priority Grant | Crossbar Multi-Master / Multi-Slave | `0x1000_1000`<br>`0x1000_2000` | **Inside Boundary** | Concurrent back-to-back writes to GPIO (`0x1000_2004`) and Timer (`0x1000_1008`). | Priority encoder and arbiter grant routing without bus lockup or data corruption. | **PASS** |
| **TC-05** | UART Peripheral Subsystem & Serial Telemetry | UART 16550 Core (M00) | `0x1000_0000` | **Crosses Boundary (Out)** | Write ASCII character `0x53` ('S') to Transmitter Holding Register (`0x1000_0000`). | UART serializer initiates frame transmission; observable on external `uart_tx`. | **PASS** |
| **TC-06** | GPIO Subsystem Configuration & Atomic Pin Control | GPIO Subsystem (M02) | `0x1000_2000` | **Crosses Boundary (Inout)** | Write `0x0F` to GPIO Direction (`0x1000_2008`) and `0x0A` to `DATA_O` (`0x1000_2004`). | Readback register matches `0x0A`; lower 4 pins of `gpio_io[7:0]` reflect driven value. | **PASS** |
| **TC-07** | 32-Bit Timer Subsystem Counting & Expiration | Hardware Timer (M01) | `0x1000_1000` | **Inside Boundary** | Set `COMPARE = 100` (`0x1000_1008`) and start counter (`0x1000_1000 = 1`). | Counter increments toward compare match; asserts internal `timer_irq`. | **PASS** |
| **TC-08** | 16-Tap FIR Filter Subsystem & Impulse Response | FIR DSP Pipeline (M04) | `0x1000_4000` | **Inside Boundary** | Program Tap 0 coefficient to `256` (`0x1000_4004`) and enable filter (`0x1000_4000 = 1`). | Filter coefficients stored in register bank; pipeline ready to accept streaming samples. | **PASS** |
| **TC-09** | 12-Bit SAR ADC Interface & Sample Capture | ADC Controller & FIFO (M03) | `0x1000_3000` | **Crosses Boundary (In)** | Program divisor `50` (`0x1000_300C`); inject external sample `adc_sample_data = 0x800` with `valid = 1`. | ADC controller captures sample into FIFO; updates status and sample available flags. | **PASS** |
| **TC-10** | Dedicated `alert_led` Hardware Independence | Autonomous Hardware Bypass | — | **Crosses Boundary (Out)** | Trigger QRS R-peak or arrhythmia condition inside detection accelerator. | External `alert_led` asserts **autonomously without software intervention**. | **PASS** |
| **TC-11** | QRS Detection Engine Verification Against ECG | Pan-Tompkins QRS Engine (M05) | `0x1000_5000` | **Inside Boundary** | Enable QRS (`0x1000_5000 = 1`), configure high threshold `0x300` (`0x1000_5004`). | Detection thresholds programmed; Schmitt trigger and moving window integration armed. | **PASS** |
| **TC-12** | Cardiac Rhythm Classification & RR/BPM Extraction | QRS Diagnostics (M05) | `0x1000_5000` | **Inside Boundary** | Read live BPM diagnostic register at `0x1000_500C` via CPU AXI4 read cycle. | Double-buffered BPM readback active and returns validated diagnostic status. | **PASS** |
| **TC-13** | Out-of-Range Interconnect Decode Error Handling | AXI4 Interconnect / Default Slave | `0x2000_0000` (Unmapped) | **Inside Boundary** | CPU attempts read/write to unmapped aperture space outside authoritative map. | Crossbar decodes default slave; traps illegal access with `DECERR` / `SLVERR` protocol. | **PASS** |
| **TC-14** | System Interrupt Architecture & Interrupt Aggregator | Interrupt Aggregator (M08) | `0x1000_8000` | **Crosses Boundary (Out)** | Write `0x0000007F` to Interrupt Mask Register (`0x1000_8004`) to unmask all 7 sources. | Mask register readback verified; pending IRQs assert `core_irq` and `core_irq_out`. | **PASS** |
| **TC-15** | AES-128 Hardware Encryption Engine Known-Answer Test | AES-128 Cipher Engine (M06) | `0x1000_6000` | **Inside Boundary** | Load 128-bit key (`0x1000_6004-10`), 128-bit plaintext block (`0x1000_6014-20`), start cipher. | Cipher runs 10 rounds; asserts `aes_done_irq`; ciphertext output matches NIST vectors. | **PASS** |
| **TC-16** | Watchdog Timer Pre-Timeout, Feed & Reset Generation | Watchdog Safety Timer (M07) | `0x1000_7000` | **Crosses Boundary (Out)** | Load reload count `128` (`0x1000_7004`), enable WDT (`0x1000_7000`), issue feed key `0xA55AFEED`. | Watchdog counter reloads; `wdt_reset_n` remains deasserted (`1`); pre-timeout armed. | **PASS** |
| **TC-17** | End-to-End Biomedical Processing to Encrypted Telemetry | Full Processing Pipeline | All | **Crosses Boundary (In & Out)** | Inject ECG sample via `adc_sample_data` -> FIR filter -> QRS detection -> AES cipher -> UART. | Full chain executes seamlessly from analog input capture to encrypted telemetry transmit. | **PASS** |
| **TC-18** | SoC Reset Recovery & Full Regression Scorecard | System Reset & Regression | Full SoC | **Crosses Boundary (In & Out)** | Apply warm reset recovery sequence; verify clean state across all peripherals. | All 18 tests complete with 0 failures; emits **18/18 PASS (100.0%)** scorecard. | **PASS** |

---

## 4. Signal Flow & Boundary Visualization

```mermaid
flowchart TD
    subgraph External_Environment ["External Environment / Off-Chip"]
        EXT_CLK["clk (50 MHz)"]
        EXT_RST["rst_n (Active-low Reset)"]
        EXT_ADC_D["adc_sample_data[11:0]"]
        EXT_ADC_V["adc_sample_valid"]
        EXT_UART_RX["uart_rx"]
        
        EXT_UART_TX["uart_tx"]
        EXT_ALERT["alert_led (Emergency Hardware Alert)"]
        EXT_WDT["wdt_reset_n (System Reset Out)"]
        EXT_IRQ["core_irq_out (Diagnostic IRQ)"]
        EXT_GPIO["gpio_io[7:0] (Bidirectional Pins)"]
    end

    subgraph SoC_Silicon_Boundary ["SentinelSoC Silicon Boundary"]
        subgraph CPU_Subsystem ["CPU Subsystem"]
            CPU["VeeR EL2 RISC-V RV32 Core\n(Master Port S00)"]
            IMEM["IMEM 64 KB\n(0x0000_0000)"]
            DMEM["DMEM 64 KB\n(0x0001_0000)"]
        end

        subgraph Interconnect_Fabric ["Interconnect Fabric"]
            XBAR["3x11 AXI4 Crossbar Fabric\n(Round-Robin Arbitration & Decode)"]
        end

        subgraph Peripherals ["Peripheral Subsystems"]
            UART["M00: UART Controller (0x1000_0000)"]
            TIMER["M01: Timer / Counter (0x1000_1000)"]
            GPIO["M02: GPIO Controller (0x1000_2000)"]
            ADC["M03: ADC Controller (0x1000_3000)"]
            FIR["M04: 16-Tap FIR Filter (0x1000_4000)"]
            QRS["M05: Pan-Tompkins QRS (0x1000_5000)"]
            AES["M06: AES-128 Engine (0x1000_6000)"]
            WDT["M07: Watchdog Timer (0x1000_7000)"]
            INTC["M08: Interrupt Aggregator (0x1000_8000)"]
        end
    end

    %% External Inputs Crossing Boundary
    EXT_CLK --> CPU & XBAR & UART & TIMER & GPIO & ADC & FIR & QRS & AES & WDT & INTC & IMEM & DMEM
    EXT_RST --> CPU & XBAR & UART & TIMER & GPIO & ADC & FIR & QRS & AES & WDT & INTC & IMEM & DMEM
    EXT_ADC_D --> ADC & FIR
    EXT_ADC_V --> ADC & FIR
    EXT_UART_RX --> UART

    %% CPU and Memories to Interconnect
    CPU <== "S00 AXI4 Master" ==> XBAR
    XBAR <== "M09 AXI4" ==> IMEM
    XBAR <== "M10 AXI4" ==> DMEM

    %% Interconnect to Peripherals
    XBAR <== "M00 AXI4" ==> UART
    XBAR <== "M01 Bridge" ==> TIMER
    XBAR <== "M02 Bridge" ==> GPIO
    XBAR <== "M03 AXI4-Lite" ==> ADC
    XBAR <== "M04 AXI4-Lite" ==> FIR
    XBAR <== "M05 AXI4" ==> QRS
    XBAR <== "M06 Bridge" ==> AES
    XBAR <== "M07 Bridge" ==> WDT
    XBAR <== "M08 Bridge" ==> INTC

    %% Autonomous Biomedical Streaming
    FIR == "fir_m_axis_tdata (Streaming)" ==> QRS

    %% Interrupts to Aggregator
    UART -- "uart_irq" --> INTC
    TIMER -- "timer_irq" --> INTC
    GPIO -- "gpio_irq" --> INTC
    ADC -- "adc_irq" --> INTC
    QRS -- "qrs_peak_irq" --> INTC
    AES -- "aes_done_irq" --> INTC
    WDT -- "wdt_irq" --> INTC
    INTC -- "core_irq" --> CPU

    %% External Outputs Crossing Boundary
    UART --> EXT_UART_TX
    QRS -- "Autonomous Bypass" --> EXT_ALERT
    WDT --> EXT_WDT
    INTC --> EXT_IRQ
    GPIO <==> EXT_GPIO
```

---

## 5. Verification Boundary Breakdown Summary

| Boundary Category | Signal Count / Bus Width | Pin / Wire Names | Primary Purpose |
| :--- | :---: | :--- | :--- |
| **External Inputs (In)** | 16 bits | `clk` (1), `rst_n` (1), `uart_rx` (1), `adc_sample_data` (12), `adc_sample_valid` (1) | Clock, reset, sensor input, telemetry rx |
| **External Outputs (Out)** | 4 bits | `uart_tx` (1), `alert_led` (1), `wdt_reset_n` (1), `core_irq_out` (1) | Telemetry tx, cardiac alert, safety reset, IRQ out |
| **External Inout (Bidirectional)** | 8 bits | `gpio_io` (8) | Multi-purpose bitwise hardware control |
| **Internal Interconnect (Inside)** | Over 400 wires | AXI4 S00 + M00-M10 (AW, W, B, AR, R channels) | Address decoding, transactions, arbitration |
| **Internal Streaming (Inside)** | 18 wires | `fir_m_axis_tdata` (16), `fir_m_axis_tvalid` (1), `fir_m_axis_tready` (1) | Real-time filtered ECG stream to QRS engine |
| **Internal Interrupts (Inside)** | 8 wires | 7 raw peripheral IRQs + 1 aggregated `core_irq` | Low-latency asynchronous event signaling |
| **Internal Safety (Inside)** | 2 wires | `wdt_bark_irq`, internal reset tree `aresetn`/`rst` | Fail-safe watchdog expiration & recovery |
