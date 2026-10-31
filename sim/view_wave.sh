#!/bin/bash
# ==============================================================================
# SentinelSoC — Waveform Viewer Launcher
# ==============================================================================

# Tool Setup
export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

MODE=${1:-verdi}

case "$MODE" in
    verdi)
        echo "=== Launching Synopsys Verdi with FSDB & Design KDB ==="
        if [ ! -f sentinelsoc.fsdb ]; then
            echo "[-] Error: sentinelsoc.fsdb not found. Run ./run.sh first."
            exit 1
        fi
        verdi -dbdir simv.daidir -ssf sentinelsoc.fsdb &
        ;;
    dve)
        echo "=== Launching Synopsys DVE with VPD Waveform ==="
        if [ ! -f sentinelsoc.vpd ]; then
            if [ -f sentinelsoc.vcd ]; then
                echo "[+] Converting sentinelsoc.vcd to sentinelsoc.vpd..."
                vcd2vpd sentinelsoc.vcd sentinelsoc.vpd
            else
                echo "[-] Error: sentinelsoc.vcd/sentinelsoc.vpd not found."
                exit 1
            fi
        fi
        dve -full64 -vpd sentinelsoc.vpd &
        ;;
    gtkwave)
        echo "=== Launching GTKWave with VCD ==="
        if [ ! -f sentinelsoc.vcd ]; then
            echo "[-] Error: sentinelsoc.vcd not found. Run ./run.sh first."
            exit 1
        fi
        gtkwave sentinelsoc.vcd &
        ;;
    *)
        echo "Usage: $0 [verdi | dve | gtkwave]"
        exit 1
        ;;
esac
