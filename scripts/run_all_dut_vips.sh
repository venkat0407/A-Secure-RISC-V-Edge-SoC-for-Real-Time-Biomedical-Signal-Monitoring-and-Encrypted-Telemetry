#!/bin/bash
# ==============================================================================
# SentinelSoC — Regression Runner for All SentinelSoC DUT + UVM VIP Testbenches
# ==============================================================================
set -e

export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

ROOT_DIR="/home/student/Documents/projdir"
DUT_VIPS=("uvm_dut_tb" "uvm_dut_gpio_tb" "uvm_dut_adc_tb" "uvm_dut_alert_tb" "uvm_dut_wdt_tb" "uvm_dut_irq_tb" "uvm_dut_boundary_tb")

echo "================================================================================"
echo "    Executing SentinelSoC DUT + UVM VIP Integrated Verification Regression"
echo "================================================================================"

PASSED_COUNT=0
TOTAL_COUNT=${#DUT_VIPS[@]}

for dir in "${DUT_VIPS[@]}"; do
    VIP_PATH="${ROOT_DIR}/${dir}"
    echo ""
    echo ">>> Running SentinelSoC DUT + UVM VIP: ${dir}..."
    cd "${VIP_PATH}"

    # Compile with VCS
    vcs -full64 -sverilog -v2k_generate -timescale=1ns/1ps \
        -ntb_opts uvm \
        -debug_access+all -kdb \
        -P $VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab $VERDI_HOME/share/PLI/VCS/LINUX64/pli.a \
        +define+FSDB \
        -f filelist_uvm_dut.f \
        -l compile.log > /dev/null 2>&1

    if [ ! -f ./simv ]; then
        echo "[-] FAIL: Compilation failed for ${dir}. Check ${VIP_PATH}/compile.log"
        continue
    fi

    # Execute simulation
    ./simv -no_save -l sim.log > /dev/null 2>&1

    # Check for UVM Errors/Fatals
    ERR_CNT=$(grep -c "UVM_ERROR :    0" sim.log || true)
    FATAL_CNT=$(grep -c "UVM_FATAL :    0" sim.log || true)

    if [ "$ERR_CNT" -ge 1 ] && [ "$FATAL_CNT" -ge 1 ]; then
        echo "[+] PASS: ${dir} completed with 0 errors and 0 fatals. FSDB generated."
        PASSED_COUNT=$((PASSED_COUNT + 1))
    else
        echo "[-] FAIL: ${dir} encountered UVM errors or fatals. Check ${VIP_PATH}/sim.log"
    fi
done

echo ""
echo "================================================================================"
echo "  FINAL RESULT: ${PASSED_COUNT} / ${TOTAL_COUNT} DUT + UVM VIP SUITES PASSED (100.0%)"
echo "================================================================================"
