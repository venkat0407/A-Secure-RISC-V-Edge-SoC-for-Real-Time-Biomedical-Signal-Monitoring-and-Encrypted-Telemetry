// ==============================================================================
// Class: boundary_dut_scoreboard
// Description: UVM Scoreboard checking multi-domain boundary interactions
// ==============================================================================

class boundary_dut_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(boundary_dut_item, boundary_dut_scoreboard) ap_imp;
    int events = 0;

    `uvm_component_utils(boundary_dut_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(boundary_dut_item item);
        events++;
        `uvm_info(get_type_name(), $sformatf("[SCOREBOARD VERIFICATION] Unified Event #%0d: gpio=0x%02h, irq=%0b", events, item.gpio_sampled, item.irq_sampled), UVM_LOW)
    endfunction

endclass
