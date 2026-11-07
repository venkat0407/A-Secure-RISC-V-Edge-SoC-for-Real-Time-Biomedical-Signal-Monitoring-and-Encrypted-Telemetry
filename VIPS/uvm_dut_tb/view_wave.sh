#!/bin/bash
# ==============================================================================
# Launch Synopsys Verdi for SentinelSoC DUT + UVM VIP Waveform Inspection
# ==============================================================================

export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

if [ ! -f sentinelsoc_uvm_dut.fsdb ]; then
    echo "[-] Error: sentinelsoc_uvm_dut.fsdb not found. Please execute ./compile_and_run.sh first."
    exit 1
fi

echo "=== Launching Synopsys Verdi with sentinelsoc_uvm_dut.fsdb, KDB, and preloaded signal layout (signals.rc) ==="
if [ -f signals.rc ]; then
    verdi -dbdir simv.daidir -ssf sentinelsoc_uvm_dut.fsdb -sswr signals.rc &
else
    verdi -dbdir simv.daidir -ssf sentinelsoc_uvm_dut.fsdb &
fi
