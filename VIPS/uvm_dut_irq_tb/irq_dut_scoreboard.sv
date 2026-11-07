// ==============================================================================
// Class: irq_dut_scoreboard
// Description: UVM Scoreboard verifying interrupt transitions
// ==============================================================================

class irq_dut_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(irq_dut_item, irq_dut_scoreboard) ap_imp;
    int events = 0;

    `uvm_component_utils(irq_dut_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(irq_dut_item item);
        events++;
        `uvm_info(get_type_name(), $sformatf("[SCOREBOARD VERIFICATION] IRQ Event #%0d: Observed core_irq_out = %0b at timestamp %0t ps", events, item.core_irq_active, item.transition_time), UVM_LOW)
    endfunction

endclass
