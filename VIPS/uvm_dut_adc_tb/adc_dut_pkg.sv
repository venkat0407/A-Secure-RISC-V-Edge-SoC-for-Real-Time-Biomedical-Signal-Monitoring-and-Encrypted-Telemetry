// ==============================================================================
// Package: adc_dut_pkg
// Description: UVM package containing all ADC VIP components
// ==============================================================================

package adc_dut_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "adc_dut_item.sv"
    `include "adc_dut_sequencer.sv"
    `include "adc_dut_sequence.sv"
    `include "adc_dut_driver.sv"
    `include "adc_dut_monitor.sv"
    `include "adc_dut_agent.sv"
    `include "adc_dut_scoreboard.sv"
    `include "adc_dut_env.sv"
    `include "adc_dut_test.sv"

endpackage
