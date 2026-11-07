// ==============================================================================
// Package: boundary_dut_pkg
// Description: UVM package containing all Unified Boundary VIP components
// ==============================================================================

package boundary_dut_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "boundary_dut_item.sv"
    `include "boundary_dut_sequencer.sv"
    `include "boundary_dut_sequence.sv"
    `include "boundary_dut_driver.sv"
    `include "boundary_dut_monitor.sv"
    `include "boundary_dut_agent.sv"
    `include "boundary_dut_scoreboard.sv"
    `include "boundary_dut_env.sv"
    `include "boundary_dut_test.sv"

endpackage
