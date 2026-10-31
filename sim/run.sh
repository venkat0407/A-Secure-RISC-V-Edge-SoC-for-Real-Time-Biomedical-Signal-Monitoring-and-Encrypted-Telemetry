#!/bin/bash
# ==============================================================================
# SentinelSoC — Simulation Execution Script
# ==============================================================================

echo "=== [2/2] Running SentinelSoC Simulation Suite ==="

if [ ! -f ./simv ]; then
    echo "[-] Error: 'simv' binary not found. Please run ./compile.sh first."
    exit 1
fi

./simv -no_save +vhx -l sim.log

echo "=== Simulation finished. Logs written to sim.log ==="
