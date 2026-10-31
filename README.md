# SentinelSoC — A Secure RISC-V Edge SoC for Real-Time Biomedical Signal Monitoring and Encrypted Telemetry

SentinelSoC is an RTL-level biomedical System-on-Chip (SoC) integrating a **RISC-V processor**, a shared 3-master × 11-slave AXI4 crossbar interconnect fabric, on-chip instruction and data memories, and dedicated peripherals for ECG acquisition, digital signal processing, cardiac event detection, and hardware cryptographic protection.

---

## System Architecture

```text
                                +-----------------------------+
                                |       RISC-V RV32 Core      |
                                |       (VeeR EL2 / RV32IM)   |
                                +--------------+--------------+
                                               |
                                     [Master Port S00: AXI4]
                                               |
  +========================================================================================+
  |                   SHARED AXI4 INTERCONNECT CROSSBAR FABRIC (3x11)                      |
  +========================================================================================+
        |           |           |           |           |           |           |
     [M00]       [M01]       [M02]       [M03]       [M04]       [M05]       [M06]
     UART        TIMER       GPIO        ADC         FIR         QRS        AES-128
   0x10000000  0x10001000  0x10002000  0x10003000  0x10004000  0x10005000  0x10006000
        |                                   |           |           |           |
        |                                   +---> Stream ---> Stream ->+        |
        |                                                              |        |
        |                                                   alert_led -+        |
        |                                                   (Hardware)          |
        |                                                                       |
     [M07] Watchdog Timer (WDT)     - 0x1000_7000 (pre-timeout IRQ, wdt_reset_n)|
     [M08] Interrupt Aggregator     - 0x1000_8000 (7 interrupt sources, CAUSE/MASK)
     [M09] Instruction Memory (IMEM)- 0x0000_0000 (64 KB SRAM)
     [M10] Data Memory (DMEM)       - 0x0001_0000 (64 KB SRAM)
```

---

## Authoritative Memory Map

| Slave Port | Peripheral / Memory | Base Address | Size | Description |
| :--- | :--- | :--- | :--- | :--- |
| **M00** | UART Controller | `0x1000_0000` | 4 KB | 8N1 serial communication & telemetry |
| **M01** | Timer / Counter | `0x1000_1000` | 4 KB | 32-bit compare timer with interrupt |
| **M02** | GPIO Subsystem | `0x1000_2000` | 4 KB | 8-bit bidirectional I/O with maskable IRQ |
| **M03** | ADC Controller | `0x1000_3000` | 4 KB | 12-bit SAR ADC interface with FIFO |
| **M04** | FIR Filter Engine | `0x1000_4000` | 4 KB | 16-tap configurable digital filter |
| **M05** | QRS Detection Accelerator | `0x1000_5000` | 4 KB | Real-time R-peak detector, RR interval, BPM |
| **M06** | AES-128 Encryption Engine | `0x1000_6000` | 4 KB | Hardware cipher for secure telemetry |
| **M07** | Watchdog Timer (WDT) | `0x1000_7000` | 4 KB | System safety timer with reset generation |
| **M08** | Interrupt Aggregator | `0x1000_8000` | 4 KB | CAUSE/MASK register block for 7 IRQ sources |
| **M09** | IMEM (Instruction SRAM) | `0x0000_0000` | 64 KB | Reset vector `0x0000_0000` |
| **M10** | DMEM (Data SRAM) | `0x0001_0000` | 64 KB | Stack top `0x0001_8000`, Mailbox at `0x0001_0FF0` |

---

## Repository Structure

```
├── doc/
│   ├── SentinelSoC_Detailed_Spec.docx     # RTL Design Specification Revision 1
│   ├── SentinelSoC_Detailed_Spec_v2.docx  # Finalized AXI4 Specification Revision 2
│   ├── SENTINELSOC_RISCV_SOC_VERIFICATION_REPORT.md # Regression scorecard & report
│   └── address_mapping.md                 # Complete memory map documentation
├── firmware/
│   ├── Makefile                           # Firmware build automation
│   ├── sentinelsoc.ld                     # Linker script for 64 KB IMEM / 64 KB DMEM
│   ├── start.S                            # Boot assembly & vector initialization
│   ├── sentinelsoc_test.c                 # C test suite exercising all 9 peripherals
│   ├── sentinelsoc_test.s                 # Assembly application for bare-metal boot
│   ├── sentinelsoc_memory_map.h           # Register offset definitions
│   ├── ecg_dataset.h / ecg_dataset.s      # Clinical MIT-BIH ECG sample datasets
│   └── build_firmware.py                  # Standalone pure-Python assembler & builder
├── rtl/
│   ├── ADC/                               # 12-bit SAR ADC controller, FIFO & scheduler
│   ├── FIR/                               # 16-tap FIR DSP pipeline & AXI wrapper
│   ├── QRS/                               # WTSEE V6 Pan-Tompkins R-peak detector
│   ├── AES/                               # Hardware AES-128 core & AXI slave wrapper
│   ├── wdt/                               # Watchdog timer with reset generation
│   ├── interrupt/                         # Interrupt aggregator (CAUSE & MASK)
│   ├── gpio/                              # 8-bit GPIO controller with bit manipulation
│   ├── timer/                             # 32-bit hardware timer
│   ├── uart/                              # 16550-compatible UART core
│   ├── interconnect/                      # AXI4 3x11 crossbar & arbiters
│   ├── common/                            # AXI4-to-AXI4Lite bridges & adapters
│   ├── riscv/                             # VeeR EL2 wrapper & memory slaves
│   └── sentinelsoc_top.sv                 # Top-level SoC integration module
├── scripts/
│   └── axi_interconnect_wrap.py           # AXI interconnect generator
├── sim/
│   ├── filelist_sentinelsoc.f             # VCS simulation filelist
│   ├── compile.sh                         # VCS compilation script
│   ├── run.sh                             # Simulation execution script
│   ├── view_wave.sh                       # Waveform viewer launcher (Verdi / DVE / GTKWave)
│   └── clean.sh                           # Cleanup script
└── tb/
    ├── tb_sentinelsoc_top.sv              # Comprehensive 18-test SoC testbench
    ├── axi_bfm_tasks.sv                   # AXI4 bus functional model tasks
    └── ecg_input.txt                      # ECG input test vector
```

---

## How to Build and Run

### 1. Build Firmware (Optional / Pre-generated)

The firmware is already pre-compiled into `sentinelsoc_test.vhx` and `sentinelsoc_test.elf`. If you modify `sentinelsoc_test.c` or `sentinelsoc_test.s`, regenerate the binaries:

```bash
cd /home/student/092/firmware
python3 build_firmware.py
```

### 2. Compile RTL with Synopsys VCS

Change to the simulation directory and run the compilation script:

```bash
cd /home/student/092/sim
./compile.sh
```

This compiles all Verilog/SystemVerilog RTL blocks, the interconnect crossbar, memories, and the 18-test verification testbench into the simulation executable `simv`.

### 3. Run Simulation

Execute the 18-test regression suite:

```bash
cd /home/student/092/sim
./run.sh
```

**Expected Result:**
```
================================================================
         SENTINELSOC 18-TEST VERIFICATION REGRESSION SCORECARD
================================================================
  [01/18] PASS | RISC-V CPU Boot & SoC Reset Bring-Up
  [02/18] PASS | Data Memory Access & SRAM Read/Write Integrity
  [03/18] PASS | AXI4 Interconnect Address Mapping & Handshake Protocol
  [04/18] PASS | Bus Contention & Interconnect Priority Grant
  [05/18] PASS | UART Peripheral Subsystem & Serial Telemetry
  [06/18] PASS | GPIO Subsystem Configuration & Atomic Pin Control
  [07/18] PASS | 32-Bit Timer Subsystem Counting & Expiration
  [08/18] PASS | 16-Tap FIR Filter Subsystem & Impulse Response
  [09/18] PASS | 12-Bit SAR ADC Interface & Sample Capture
  [10/18] PASS | Dedicated alert_led Hardware Independence
  [11/18] PASS | QRS Detection Engine Verification Against ECG
  [12/18] PASS | Cardiac Rhythm Classification & RR/BPM Extraction
  [13/18] PASS | Out-of-Range Interconnect Decode Error Handling
  [14/18] PASS | System Interrupt Architecture & Interrupt Aggregator
  [15/18] PASS | AES-128 Hardware Encryption Engine Known-Answer Test
  [16/18] PASS | Watchdog Timer Pre-Timeout, Feed & Reset Generation
  [17/18] PASS | End-to-End Biomedical Processing to Encrypted Telemetry
  [18/18] PASS | SoC Reset Recovery & Regression Scorecard
================================================================
  FINAL RESULT: 18 / 18 TEST CASES PASSED (100.0%)
================================================================
```

### 4. Inspect Waveforms

You can inspect the generated simulation waveforms using any of the following methods:

#### Method A: Using the Helper Script
```bash
cd /home/student/092/sim
./view_wave.sh verdi       # Opens Verdi with sentinelsoc.fsdb and simv.daidir KDB
./view_wave.sh dve         # Opens Synopsys DVE with sentinelsoc.vpd
./view_wave.sh gtkwave     # Opens GTKWave with sentinelsoc.vcd
```

#### Method B: Synopsys Verdi (Recommended)
```bash
cd /home/student/092/sim
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

verdi -dbdir simv.daidir -ssf sentinelsoc.fsdb &
```

#### Method C: Synopsys DVE
```bash
cd /home/student/092/sim
export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export PATH=$VCS_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

dve -full64 -vpd sentinelsoc.vpd &
```

#### Method D: GTKWave
```bash
cd /home/student/092/sim
gtkwave sentinelsoc.vcd &
```

#### Recommended Signal Hierarchies to Add:
- **System**: `tb_sentinelsoc_top.clk`, `tb_sentinelsoc_top.rst_n`
- **CPU AXI Master**: `dut.s00_axi_awaddr`, `dut.s00_axi_wdata`, `dut.s00_axi_araddr`, `dut.s00_axi_rdata`
- **Biomedical Processing Pipeline**: `dut.adc_sample_data[11:0]`, `dut.fir_m_axis_tdata[15:0]`, `dut.u_qrs.u_wtsee.r_peak`, `dut.u_qrs.u_wtsee.rhythm_class[1:0]`, `dut.alert_led`
- **Security & Safety**: `dut.u_aes.aes_done_irq`, `dut.wdt_reset_n`, `dut.core_irq_out`, `dut.timer_irq`
