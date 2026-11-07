#!/bin/bash
# ==============================================================================
# SentinelSoC DUT + ADC UVM VIP Compilation & Simulation Script with Verdi FSDB
# ==============================================================================
set -e

export VCS_HOME=/home/student/snps_tools_target/vcs/U-2023.03
export VERDI_HOME=/home/student/snps_tools_target/verdi/U-2023.03-SP1
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH
export SNPSLMD_LICENSE_FILE=27021@14.139.1.126:$SNPSLMD_LICENSE_FILE

echo "=== [1/2] Compiling SentinelSoC DUT + ADC UVM VIP with Synopsys VCS ==="

vcs -full64 -sverilog -v2k_generate -timescale=1ns/1ps \
    -ntb_opts uvm \
    -debug_access+all -kdb \
    -P $VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab $VERDI_HOME/share/PLI/VCS/LINUX64/pli.a \
    +define+FSDB \
    -f filelist_uvm_dut.f \
    -l compile.log

echo "=== Compilation Complete. Executable 'simv' created. ==="

echo "=== [2/2] Running SentinelSoC DUT + ADC UVM VIP Simulation ==="
./simv -no_save -l sim.log

echo "=== Simulation Complete. Logs written to sim.log and waveform in sentinelsoc_uvm_dut_adc.fsdb ==="
