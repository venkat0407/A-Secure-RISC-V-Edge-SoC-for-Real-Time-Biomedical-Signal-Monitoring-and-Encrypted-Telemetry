// ==============================================================================
// Class: adc_dut_sequencer
// Description: UVM Sequencer for ADC transactions
// ==============================================================================

class adc_dut_sequencer extends uvm_sequencer #(adc_dut_item);

    `uvm_component_utils(adc_dut_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
