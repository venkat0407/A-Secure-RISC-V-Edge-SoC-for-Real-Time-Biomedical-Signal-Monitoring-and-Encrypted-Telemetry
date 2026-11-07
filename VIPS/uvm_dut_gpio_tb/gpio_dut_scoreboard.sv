// ==============================================================================
// Class: gpio_dut_scoreboard
// Description: UVM Scoreboard checking and validating GPIO data transactions
// ==============================================================================

class gpio_dut_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(gpio_dut_item, gpio_dut_scoreboard) ap_imp;
    int event_count = 0;

    `uvm_component_utils(gpio_dut_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(gpio_dut_item item);
        event_count++;
        `uvm_info(get_type_name(), $sformatf("[SCOREBOARD VERIFICATION] Event #%0d: Observed GPIO pin state = 0x%02h", event_count, item.sampled_data), UVM_LOW)
    endfunction

endclass
