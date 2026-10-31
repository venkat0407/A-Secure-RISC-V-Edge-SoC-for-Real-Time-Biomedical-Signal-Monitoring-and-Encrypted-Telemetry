# SentinelSoC: RISC-V SoC Verification Report

**Project Title:** SentinelSoC — A Secure RISC-V Edge SoC for Real-Time Biomedical Signal Monitoring and Encrypted Telemetry  
**Verification Suite Status:** **18 / 18 Tests Passing (100.0%)**  
**EDA Simulation Platform:** Synopsys VCS U-2023.03_Full64 & Synopsys Verdi  

---

## 1. Executive Summary

SentinelSoC combines a 32-bit RISC-V processor subsystem, a shared 3-master × 11-slave AXI4 crossbar interconnect fabric, on-chip SRAM memories (64 KB IMEM and 64 KB DMEM), and 9 dedicated peripheral and acceleration blocks:
1. **UART Controller** (`0x1000_0000`)
2. **Timer/Counter** (`0x1000_1000`)
3. **GPIO Subsystem** (`0x1000_2000`)
4. **12-Bit SAR ADC Controller** (`0x1000_3000`)
5. **16-Tap FIR Filter Engine** (`0x1000_4000`)
6. **Pan-Tompkins QRS Detection Accelerator** (`0x1000_5000`)
7. **AES-128 Encryption Engine** (`0x1000_6000`)
8. **Watchdog Timer (WDT)** (`0x1000_7000`)
9. **Interrupt Aggregator** (`0x1000_8000`)

The verification testbench (`tb/tb_sentinelsoc_top.sv`) executes 18 architectural test cases verifying reset sequencing, bus protocol compliance, crossbar routing, hardware accelerator pipelines, cryptographic correctness, fault recovery, and end-to-end telemetry.

---

## 2. 18-Test Regression Scorecard

| Test ID | Architectural Scope | Verification Method | Status |
| :---: | :--- | :--- | :---: |
| **TC-01** | RISC-V CPU Boot & SoC Reset Bring-Up | Active-low reset deassertion & boot vector checks | **PASS** |
| **TC-02** | Data Memory Access & SRAM Integrity | Back-to-back 32-bit read/write transactions | **PASS** |
| **TC-03** | AXI4 Interconnect Address Mapping & Protocol | Read/write handshakes across peripheral apertures | **PASS** |
| **TC-04** | Bus Contention & Interconnect Priority Grant | Concurrent requests across slave apertures | **PASS** |
| **TC-05** | UART Peripheral Subsystem & Serial Telemetry | THR transmission & line status monitoring | **PASS** |
| **TC-06** | GPIO Configuration & Atomic Pin Control | Direction registers & output pin level verification | **PASS** |
| **TC-07** | 32-Bit Timer Subsystem & Expiration | Compare-match counting and interrupt generation | **PASS** |
| **TC-08** | 16-Tap FIR Filter Subsystem & Impulse Response | Tap coefficient programming and streaming pipeline | **PASS** |
| **TC-09** | 12-Bit SAR ADC Interface & Sample Capture | Sample intake, rate division, and overrun logic | **PASS** |
| **TC-10** | Dedicated `alert_led` Hardware Independence | Autonomous threshold crossing asserts alert LED pin | **PASS** |
| **TC-11** | QRS Detection Engine Verification Against ECG | Clinical ECG waveform evaluation & R-peak detection | **PASS** |
| **TC-12** | Cardiac Rhythm Classification & RR/BPM | Real-time calculation of RR interval and heart rate | **PASS** |
| **TC-13** | Out-of-Range Interconnect Decode Error Trap | Verification of bus SLVERR/DECERR handling | **PASS** |
| **TC-14** | Interrupt Architecture & Aggregator | 7-source interrupt masking and CAUSE register W1C | **PASS** |
| **TC-15** | AES-128 Hardware Encryption Engine | NIST standard 128-bit encryption cipher verification | **PASS** |
| **TC-16** | Watchdog Timer & Reset Generation | Countdown countdown, pre-timeout IRQ & FEED strobe | **PASS** |
| **TC-17** | End-to-End Biomedical to Encrypted Telemetry | ADC -> FIR -> QRS -> AES-128 -> UART pipeline | **PASS** |
| **TC-18** | SoC Reset Recovery & Full Regression Scorecard | Clean recovery after reset and 100% pass scorecard | **PASS** |

**Final Verification Result:** 18 / 18 Passing (100.0%)
