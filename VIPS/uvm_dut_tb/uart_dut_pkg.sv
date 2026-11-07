// ==============================================================================
// Package: uart_dut_pkg
// Description: UVM package containing all components and transactions for DUT-VIP verification
// ==============================================================================

package uart_dut_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "uart_dut_item.sv"
    `include "uart_dut_sequencer.sv"
    `include "uart_dut_sequence.sv"
    `include "uart_dut_driver.sv"
    `include "uart_dut_monitor.sv"
    `include "uart_dut_agent.sv"
    `include "uart_dut_scoreboard.sv"
    `include "uart_dut_env.sv"
    `include "uart_dut_test.sv"

endpackage
