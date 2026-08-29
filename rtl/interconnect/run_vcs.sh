#!/bin/bash
# ============================================================
#  VCS + Verdi Run Script
#  Design   : axi_interconnect_wrap_1x9
#  Testbench: tb_axi_interconnect_wrap_1x9
#
#  Tool paths (auto-detected on this machine):
#    VCS    : /home/student/snps_tools_target/vcs/U-2023.03
#    Verdi  : /home/student/snps_tools_target/verdi/U-2023.03-SP1
#
#  Usage:
#    ./run_vcs.sh           -> compile + simulate
#    ./run_vcs.sh verdi     -> compile + simulate + open Verdi
#    ./run_vcs.sh clean     -> remove all generated files
# ============================================================

# ---------------------------------------------------------------
# Tool installation roots (hardcoded for this machine)
# ---------------------------------------------------------------
VCS_HOME="/home/student/snps_tools_target/vcs/U-2023.03"
VERDI_HOME="/home/student/snps_tools_target/verdi/U-2023.03-SP1"

# ---------------------------------------------------------------
# Export environment variables required by VCS and Verdi
# ---------------------------------------------------------------
export VCS_HOME
export VERDI_HOME

# Add tool binaries to PATH
export PATH="${VCS_HOME}/bin:${VERDI_HOME}/bin:${PATH}"

# Verdi PLI shared library directory (linux64 for x86_64)
PLI_DIR="${VERDI_HOME}/share/PLI/VCS/linux64"

# Add Verdi shared libraries to LD_LIBRARY_PATH so simv can load them
export LD_LIBRARY_PATH="${VERDI_HOME}/share/PLI/VCS/linux64:${VERDI_HOME}/share/PLI/lib/linux64:${LD_LIBRARY_PATH}"

# ---------------------------------------------------------------
# Project settings
# ---------------------------------------------------------------
TOP_MODULE="tb_axi_interconnect_wrap_1x9"
FILELIST="file.f"
SIM_OUT="simv"
FSDB_FILE="tb_axi_interconnect_wrap_1x9.fsdb"
WORK_DIR="./vcs_work"
COMPILE_LOG="vcs_compile.log"
SIM_LOG="sim_run.log"

# Verdi PLI arguments passed to VCS at compile time
NOVAS_PLI="-P ${PLI_DIR}/novas.tab ${PLI_DIR}/pli.a"

# ---------------------------------------------------------------
# clean
# ---------------------------------------------------------------
if [ "$1" == "clean" ]; then
    echo "[INFO] Cleaning build artifacts..."
    rm -rf "${WORK_DIR}" "${SIM_OUT}" "${SIM_OUT}.daidir" \
           csrc *.log *.fsdb *.vpd ucli.key vc_hdrs.h    \
           DVEfiles novas.conf novas_dump.log              \
           compile_stdout.log sim_stdout.log
    echo "[INFO] Clean done."
    exit 0
fi

# ---------------------------------------------------------------
# Pre-flight: confirm tools exist
# ---------------------------------------------------------------
if [ ! -x "${VCS_HOME}/bin/vcs" ]; then
    echo "[ERROR] vcs not found at ${VCS_HOME}/bin/vcs"
    exit 1
fi
if [ ! -f "${PLI_DIR}/novas.tab" ]; then
    echo "[ERROR] Verdi PLI novas.tab not found at ${PLI_DIR}"
    exit 1
fi

mkdir -p "${WORK_DIR}"

# ===============================================================
#  STEP 1 — VCS COMPILE
# ===============================================================
echo "============================================================"
echo " Step 1: VCS Compile"
echo " VCS    : $(which vcs)"
echo " VERDI  : ${VERDI_HOME}"
echo " PLI    : ${PLI_DIR}"
echo "============================================================"

vcs                              \
    -full64                      \
    -sverilog                    \
    -v2k                         \
    +v2k                         \
    -timescale=1ns/1ps           \
    -debug_access+all            \
    +vcsd                        \
    -f  "${FILELIST}"            \
    -top "${TOP_MODULE}"         \
    -o  "${SIM_OUT}"             \
    -Mdir="${WORK_DIR}"          \
    +define+SIMULATION           \
    +lint=all                    \
    ${NOVAS_PLI}                 \
    -l "${COMPILE_LOG}"          \
    2>&1 | tee compile_stdout.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "[ERROR] Compilation FAILED. Check ${COMPILE_LOG}"
    exit 1
fi

echo ""
echo "[INFO] Compilation PASSED."

# ===============================================================
#  STEP 2 — SIMULATION
# ===============================================================
echo ""
echo "============================================================"
echo " Step 2: Simulation"
echo "============================================================"

./"${SIM_OUT}"       \
    -l "${SIM_LOG}"  \
    +fsdb+delta      \
    2>&1 | tee sim_stdout.log

SIM_STATUS=${PIPESTATUS[0]}

echo ""
echo "============================================================"
echo " Simulation log : ${SIM_LOG}"
echo " FSDB waveform  : ${FSDB_FILE}"
echo "============================================================"

echo ""
echo "[RESULT SUMMARY]"
grep -E "PASS|FAIL|TIMEOUT|WATCHDOG|Test Summary|ALL TESTS" sim_stdout.log || true

# ---------------------------------------------------------------
# Confirm FSDB was written
# ---------------------------------------------------------------
if [ -f "${FSDB_FILE}" ]; then
    FSDB_SIZE=$(du -sh "${FSDB_FILE}" | cut -f1)
    echo ""
    echo "[INFO] FSDB created: ${FSDB_FILE}  (${FSDB_SIZE})"
else
    echo ""
    echo "[WARN] FSDB file was NOT created."
    echo "       Check that the Verdi PLI loaded correctly in ${COMPILE_LOG}"
fi

# ===============================================================
#  STEP 3 — OPEN VERDI  (only when argument is "verdi")
# ===============================================================
if [ "$1" == "verdi" ]; then
    echo ""
    echo "============================================================"
    echo " Step 3: Opening Verdi"
    echo "============================================================"

    if [ ! -f "${FSDB_FILE}" ]; then
        echo "[ERROR] FSDB file '${FSDB_FILE}' not found."
        echo "        Simulation may have failed — check ${SIM_LOG}"
        exit 1
    fi

    verdi                      \
        -sv                    \
        -f  "${FILELIST}"      \
        -top "${TOP_MODULE}"   \
        -ssf "${FSDB_FILE}"    \
        -nologo                \
        &

    echo "[INFO] Verdi launched (PID $!)"
    echo "[INFO] In Verdi: nWave -> File -> Open FSDB if not auto-loaded"
fi

exit ${SIM_STATUS}
