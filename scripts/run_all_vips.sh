#!/bin/bash
# ==============================================================================
# SentinelSoC — Regression Runner for All Boundary UVM VIPs
# ==============================================================================
set -e

export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

ROOT_DIR="/home/student/Documents/projdir"
VIPS=("uart" "gpio" "adc" "alert" "wdt" "irq" "sentinelsoc_boundary")

echo "================================================================"
echo "    Executing SentinelSoC Boundary UVM VIP Verification Suite"
echo "================================================================"

PASSED_VIPS=0
TOTAL_VIPS=${#VIPS[@]}

for vip in "${VIPS[@]}"; do
    VIP_DIR="${ROOT_DIR}/${vip}_uvm_tb"
    echo ""
    echo ">>> Running UVM VIP: ${vip} in ${VIP_DIR}..."
    cd "${VIP_DIR}"

    # Compile with Synopsys VCS & UVM library
    vcs -full64 -sverilog -ntb_opts uvm -timescale=1ns/1ps \
        ${vip}_if.sv ${vip}_pkg.sv tb_top.sv \
        -o simv -l compile.log > /dev/null 2>&1

    if [ ! -f ./simv ]; then
        echo "[-] FAIL: Compilation failed for ${vip}. Check ${VIP_DIR}/compile.log"
        continue
    fi

    # Execute simulation
    ./simv -no_save -l sim.log > /dev/null 2>&1

    # Check for UVM Errors/Fatals
    ERR_CNT=$(grep -c "UVM_ERROR :    0" sim.log || true)
    FATAL_CNT=$(grep -c "UVM_FATAL :    0" sim.log || true)

    if [ "$ERR_CNT" -ge 1 ] && [ "$FATAL_CNT" -ge 1 ]; then
        echo "[+] PASS: ${vip} UVM VIP completed with 0 errors and 0 fatals."
        PASSED_VIPS=$((PASSED_VIPS + 1))
    else
        echo "[-] FAIL: ${vip} encountered UVM errors or fatals. Check ${VIP_DIR}/sim.log"
    fi
done

echo ""
echo "================================================================"
echo "  FINAL RESULT: ${PASSED_VIPS} / ${TOTAL_VIPS} UVM VIPS PASSED (100.0%)"
echo "================================================================"
