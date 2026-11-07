// ==============================================================================
// Package: irq_dut_pkg
// Description: UVM package containing all IRQ VIP components
// ==============================================================================

package irq_dut_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "irq_dut_item.sv"
    `include "irq_dut_sequencer.sv"
    `include "irq_dut_sequence.sv"
    `include "irq_dut_driver.sv"
    `include "irq_dut_monitor.sv"
    `include "irq_dut_agent.sv"
    `include "irq_dut_scoreboard.sv"
    `include "irq_dut_env.sv"
    `include "irq_dut_test.sv"

endpackage
