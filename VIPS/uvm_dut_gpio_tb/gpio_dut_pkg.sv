// ==============================================================================
// Package: gpio_dut_pkg
// Description: UVM package containing all GPIO VIP components
// ==============================================================================

package gpio_dut_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "gpio_dut_item.sv"
    `include "gpio_dut_sequencer.sv"
    `include "gpio_dut_sequence.sv"
    `include "gpio_dut_driver.sv"
    `include "gpio_dut_monitor.sv"
    `include "gpio_dut_agent.sv"
    `include "gpio_dut_scoreboard.sv"
    `include "gpio_dut_env.sv"
    `include "gpio_dut_test.sv"

endpackage
