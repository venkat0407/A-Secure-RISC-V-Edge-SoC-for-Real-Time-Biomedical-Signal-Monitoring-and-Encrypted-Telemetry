# AXI Interconnect 1×9 — RTL Verification

Verilog RTL implementation and VCS/Verdi simulation environment for a
**1-slave to 9-master AXI4 interconnect**.  
All 9 write + read transactions pass verified against expected data patterns.

---

## Project Structure

```
interconnect/
├── README.md                          ← this file
│
├── RTL Sources
│   ├── priority_encoder.v             ← leaf: parameterised priority encoder
│   ├── arbiter.v                      ← round-robin arbiter (uses priority_encoder)
│   ├── axi_interconnect.v             ← AXI4 interconnect core (address decode + routing)
│   └── axi_interconnect_wrap_1x9.v   ← top-level wrapper (1 slave, 9 masters)
│
├── Verification
│   ├── tb_axi_interconnect_wrap_1x9.v ← testbench + AXI slave memory models
│   └── file.f                         ← VCS filelist (compile order)
│
└── Scripts
    └── run_vcs.sh                     ← compile / simulate / open Verdi
```

---

## Design Overview

### Block Diagram

```
                  ┌─────────────────────────────────────┐
  AXI Master      │       axi_interconnect_wrap_1x9      │
  (testbench) ───►│ s00  ┌──────────────────────────┐   │
                  │      │    axi_interconnect core  │   │──► m00  (slave mem 0)
                  │      │  ┌──────────┐             │   │──► m01  (slave mem 1)
                  │      │  │ arbiter  │  addr       │   │──► m02  (slave mem 2)
                  │      │  │ (RR)     │  decode     │   │──► m03  (slave mem 3)
                  │      │  └──────────┘  + route    │   │──► m04  (slave mem 4)
                  │      │  ┌──────────┐             │   │──► m05  (slave mem 5)
                  │      │  │ priority │             │   │──► m06  (slave mem 6)
                  │      │  │ encoder  │             │   │──► m07  (slave mem 7)
                  │      │  └──────────┘             │   │──► m08  (slave mem 8)
                  │      └──────────────────────────┘   │
                  └─────────────────────────────────────┘
```

### Module Hierarchy

| Module | File | Description |
|---|---|---|
| `axi_interconnect_wrap_1x9` | `axi_interconnect_wrap_1x9.v` | Top wrapper, exposes named per-port signals |
| `axi_interconnect` | `axi_interconnect.v` | Core: AW/W/B/AR/R channel FSMs, address decoder |
| `arbiter` | `arbiter.v` | Round-robin arbiter with block-on-acknowledge |
| `priority_encoder` | `priority_encoder.v` | LSB/MSB configurable priority encoder |

### Key Parameters

| Parameter | Default | Description |
|---|---|---|
| `DATA_WIDTH` | 32 | AXI data bus width (bits) |
| `ADDR_WIDTH` | 32 | AXI address bus width (bits) |
| `ID_WIDTH` | 8 | AXI ID field width (bits) |
| `M_REGIONS` | 1 | Address regions per master |
| `M_ADDR_WIDTH` | 24 bits each | Each master maps a 16 MB region |

### Address Map

Address regions are auto-calculated by `calcBaseAddrs()` inside `axi_interconnect`
when `M_BASE_ADDR = 0`.  With `M_ADDR_WIDTH = 24` (16 MB per master):

| Master Port | Base Address | End Address | Size |
|---|---|---|---|
| m00 | `0x0000_0000` | `0x00FF_FFFF` | 16 MB |
| m01 | `0x0100_0000` | `0x01FF_FFFF` | 16 MB |
| m02 | `0x0200_0000` | `0x02FF_FFFF` | 16 MB |
| m03 | `0x0300_0000` | `0x03FF_FFFF` | 16 MB |
| m04 | `0x0400_0000` | `0x04FF_FFFF` | 16 MB |
| m05 | `0x0500_0000` | `0x05FF_FFFF` | 16 MB |
| m06 | `0x0600_0000` | `0x06FF_FFFF` | 16 MB |
| m07 | `0x0700_0000` | `0x07FF_FFFF` | 16 MB |
| m08 | `0x0800_0000` | `0x08FF_FFFF` | 16 MB |

---

## Testbench

### Architecture

```
tb_axi_interconnect_wrap_1x9  (top)
 ├── dut : axi_interconnect_wrap_1x9
 ├── u_mem00 : axi_slave_mem  ← 256×32-bit SRAM behind m00
 ├── u_mem01 : axi_slave_mem  ← 256×32-bit SRAM behind m01
 │   ...
 └── u_mem08 : axi_slave_mem  ← 256×32-bit SRAM behind m08
```

### Test Sequence

1. **Reset** — 5 clock cycles, 100 MHz clock (10 ns period)
2. **Write Phase** — 9 single-beat AXI4 writes, one per master port, each with a unique data pattern
3. **Read & Verify Phase** — 9 reads from the same addresses; each result is checked against expected data

### Write Data Patterns

| Master | Address | Data Written |
|---|---|---|
| m00 | `0x0000_0010` | `0xDEAD_0000` |
| m01 | `0x0100_0010` | `0xBEEF_0001` |
| m02 | `0x0200_0010` | `0xCAFE_0002` |
| m03 | `0x0300_0010` | `0xF00D_0003` |
| m04 | `0x0400_0010` | `0xA5A5_0004` |
| m05 | `0x0500_0010` | `0x5A5A_0005` |
| m06 | `0x0600_0010` | `0x1234_0006` |
| m07 | `0x0700_0010` | `0xABCD_0007` |
| m08 | `0x0800_0010` | `0x9876_0008` |

### Waveform Dump

The testbench generates an FSDB file for viewing in Verdi:

```verilog
$fsdbDumpfile("tb_axi_interconnect_wrap_1x9.fsdb");
$fsdbDumpvars(0, tb_axi_interconnect_wrap_1x9);  // full hierarchy
$fsdbDumpMDA (0, tb_axi_interconnect_wrap_1x9);  // memories / arrays
$fsdbDumpSVA (0, tb_axi_interconnect_wrap_1x9);  // assertions
```

---

## Tool Setup

### Installed Tool Paths (this machine)

| Tool | Version | Path |
|---|---|---|
| VCS | U-2023.03 | `/home/student/snps_tools_target/vcs/U-2023.03` |
| Verdi | U-2023.03-SP1 | `/home/student/snps_tools_target/verdi/U-2023.03-SP1` |
| Verdi PLI | linux64 | `$VERDI_HOME/share/PLI/VCS/linux64/` |

The `run_vcs.sh` script sets `VCS_HOME`, `VERDI_HOME`, `PATH`, and
`LD_LIBRARY_PATH` automatically — no manual export required.

---

## Running the Simulation

### Quick Start

```bash
cd /home/student/Documents/nani/rtl/interconnect

# Compile + simulate
./run_vcs.sh

# Compile + simulate + open Verdi with waveform
./run_vcs.sh verdi

# Remove all generated files
./run_vcs.sh clean
```

### Step-by-Step (manual)

```bash
# 1. Set environment
export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH
export LD_LIBRARY_PATH=$VERDI_HOME/share/PLI/VCS/linux64:$LD_LIBRARY_PATH

# 2. Compile
PLI_DIR=$VERDI_HOME/share/PLI/VCS/linux64
vcs -full64 -sverilog -v2k +v2k -timescale=1ns/1ps \
    -debug_access+all +vcsd \
    -P $PLI_DIR/novas.tab $PLI_DIR/pli.a \
    -f file.f -top tb_axi_interconnect_wrap_1x9 -o simv

# 3. Simulate
./simv +fsdb+delta

# 4. Open Verdi
verdi -sv -f file.f -top tb_axi_interconnect_wrap_1x9 \
      -ssf tb_axi_interconnect_wrap_1x9.fsdb -nologo &
```

---

## Expected Simulation Output

```
============================================================
 AXI Interconnect 1x9 Testbench
 Testing WRITE then READ to all 9 master ports
============================================================

--- WRITE PHASE ---

--- READ & VERIFY PHASE ---
PASS: addr=0x00000010  exp=0xdead0000  got=0xdead0000
PASS: addr=0x01000010  exp=0xbeef0001  got=0xbeef0001
PASS: addr=0x02000010  exp=0xcafe0002  got=0xcafe0002
PASS: addr=0x03000010  exp=0xf00d0003  got=0xf00d0003
PASS: addr=0x04000010  exp=0xa5a50004  got=0xa5a50004
PASS: addr=0x05000010  exp=0x5a5a0005  got=0x5a5a0005
PASS: addr=0x06000010  exp=0x12340006  got=0x12340006
PASS: addr=0x07000010  exp=0xabcd0007  got=0xabcd0007
PASS: addr=0x08000010  exp=0x98760008  got=0x98760008

============================================================
 Test Summary: PASS=9  FAIL=0  (Total=9)
============================================================
 ALL TESTS PASSED
```

Simulation finishes at **2625 ns** with 9/9 tests passing.

---

## Viewing Waveforms in Verdi

After running `./run_vcs.sh verdi`:

1. **Add signals** — In the nWave window press `Ctrl+W` or go to
   `Signal → Get Signals`
2. **Slave-side traffic** — Expand `tb_axi_interconnect_wrap_1x9` and add:
   - `clk`, `rst`
   - All `s00_axi_aw*` signals (Write Address channel)
   - All `s00_axi_w*` signals (Write Data channel)
   - All `s00_axi_b*` signals (Write Response channel)
   - All `s00_axi_ar*` signals (Read Address channel)
   - All `s00_axi_r*` signals (Read Data channel)
3. **Per-master traffic** — Expand `dut` and add `m00_axi_*` through `m08_axi_*`
   to verify correct address routing to each slave
4. **AXI transaction view** — Right-click a bus group → `Set as AXI Protocol`
   for a decoded transaction overlay

### Key Signals to Watch

| Signal Group | What to look for |
|---|---|
| `s00_axi_aw*` | `awvalid` / `awready` handshake; `awaddr` routing to correct master |
| `s00_axi_w*` | `wvalid` / `wready` handshake; `wdata` value |
| `s00_axi_b*` | `bvalid` / `bready`; `bresp = 2'b00` (OKAY) |
| `s00_axi_ar*` | `arvalid` / `arready`; `araddr` routing |
| `s00_axi_r*` | `rvalid` / `rready`; `rdata` matches written value |
| `mXX_axi_aw*` | Confirm only the target master port goes active per transaction |

---

## Generated Output Files

| File | Description |
|---|---|
| `simv` | Compiled simulation binary |
| `simv.daidir/` | VCS elaboration database |
| `vcs_work/` | VCS intermediate compile objects |
| `tb_axi_interconnect_wrap_1x9.fsdb` | Verdi waveform database |
| `vcs_compile.log` | VCS compilation log |
| `sim_run.log` | Simulation run log |
| `novas_dump.log` | Verdi FSDB writer log |
| `verdiLog/` | Verdi session files |

To remove all generated files:
```bash
./run_vcs.sh clean
```

---

## License

RTL source files (`axi_interconnect*.v`, `arbiter.v`, `priority_encoder.v`)  
Copyright © 2018–2020 Alex Forencich — MIT License.

Testbench and run scripts authored for this project.
