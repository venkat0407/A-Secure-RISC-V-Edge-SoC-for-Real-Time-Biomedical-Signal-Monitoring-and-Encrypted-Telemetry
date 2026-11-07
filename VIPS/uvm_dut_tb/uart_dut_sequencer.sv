// ==============================================================================
// Class: uart_dut_sequencer
// Description: UVM Sequencer routing sequence items to the driver
// ==============================================================================

class uart_dut_sequencer extends uvm_sequencer #(uart_dut_item);

    `uvm_component_utils(uart_dut_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
