#!/bin/bash
# ==============================================================================
# SentinelSoC — Synopsys VCS Compilation Script with Verdi FSDB Waveform Support
# ==============================================================================
set -e

# Synopsys Environment Setup
export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

echo "=== [1/2] Compiling SentinelSoC RTL & Testbench with Synopsys VCS ==="

vcs -full64 -sverilog -v2k_generate -timescale=1ns/1ps \
    -debug_access+all -kdb \
    -P $VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab $VERDI_HOME/share/PLI/VCS/LINUX64/pli.a \
    +define+FSDB \
    -f filelist_sentinelsoc.f \
    -l compile.log

echo "=== Compilation Complete. Executable 'simv' created. ==="
