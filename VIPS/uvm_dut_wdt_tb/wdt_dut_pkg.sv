// ==============================================================================
// Package: wdt_dut_pkg
// Description: UVM package containing all Watchdog VIP components
// ==============================================================================

package wdt_dut_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "wdt_dut_item.sv"
    `include "wdt_dut_sequencer.sv"
    `include "wdt_dut_sequence.sv"
    `include "wdt_dut_driver.sv"
    `include "wdt_dut_monitor.sv"
    `include "wdt_dut_agent.sv"
    `include "wdt_dut_scoreboard.sv"
    `include "wdt_dut_env.sv"
    `include "wdt_dut_test.sv"

endpackage
