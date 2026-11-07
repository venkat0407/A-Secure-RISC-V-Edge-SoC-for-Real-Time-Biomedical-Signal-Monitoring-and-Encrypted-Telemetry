#!/bin/bash
# ==============================================================================
# Launch Synopsys Verdi with Preloaded Alert LED Signal Layout
# ==============================================================================

export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

FSDB_FILE="sentinelsoc_uvm_dut_alert.fsdb"
RC_FILE="signals.rc"

if [ ! -f "$FSDB_FILE" ]; then
    echo "[-] Error: Waveform file '$FSDB_FILE' not found. Run ./compile_and_run.sh first."
    exit 1
fi

echo "[+] Opening Synopsys Verdi with $FSDB_FILE and $RC_FILE..."
verdi -dbdir simv.daidir -ssf "$FSDB_FILE" -sswr "$RC_FILE" &
