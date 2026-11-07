// ==============================================================================
// Class: gpio_dut_sequencer
// Description: UVM Sequencer for GPIO transactions
// ==============================================================================

class gpio_dut_sequencer extends uvm_sequencer #(gpio_dut_item);

    `uvm_component_utils(gpio_dut_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
