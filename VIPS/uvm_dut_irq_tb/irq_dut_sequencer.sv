// ==============================================================================
// Class: irq_dut_sequencer
// Description: UVM Sequencer for IRQ VIP
// ==============================================================================

class irq_dut_sequencer extends uvm_sequencer #(irq_dut_item);

    `uvm_component_utils(irq_dut_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
