// ==============================================================================
// Class: irq_dut_item
// Description: UVM Sequence Item representing an Interrupt event
// ==============================================================================

class irq_dut_item extends uvm_sequence_item;

    bit  core_irq_active;
    time transition_time;

    `uvm_object_utils_begin(irq_dut_item)
        `uvm_field_int(core_irq_active, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(transition_time, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "irq_dut_item");
        super.new(name);
    endfunction

endclass
