// ==============================================================================
// Class: irq_dut_sequence
// Description: UVM Sequence for IRQ VIP
// ==============================================================================

class irq_dut_sequence extends uvm_sequence #(irq_dut_item);

    `uvm_object_utils(irq_dut_sequence)

    function new(string name = "irq_dut_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "=== Starting IRQ VIP Sequence: Supervising core_irq_out diagnostic line ===", UVM_LOW)
        #3000ns;
        `uvm_info(get_type_name(), "=== IRQ VIP Sequence Completed ===", UVM_LOW)
    endtask

endclass
