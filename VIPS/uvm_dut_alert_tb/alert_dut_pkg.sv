// ==============================================================================
// Package: alert_dut_pkg
// Description: UVM package containing all Alert VIP components
// ==============================================================================

package alert_dut_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "alert_dut_item.sv"
    `include "alert_dut_sequencer.sv"
    `include "alert_dut_sequence.sv"
    `include "alert_dut_driver.sv"
    `include "alert_dut_monitor.sv"
    `include "alert_dut_agent.sv"
    `include "alert_dut_scoreboard.sv"
    `include "alert_dut_env.sv"
    `include "alert_dut_test.sv"

endpackage
