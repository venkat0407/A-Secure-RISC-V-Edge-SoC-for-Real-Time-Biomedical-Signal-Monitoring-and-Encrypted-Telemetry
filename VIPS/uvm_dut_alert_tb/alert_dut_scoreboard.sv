// ==============================================================================
// Class: alert_dut_scoreboard
// Description: UVM Scoreboard confirming autonomous alert LED trigger
// ==============================================================================

class alert_dut_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(alert_dut_item, alert_dut_scoreboard) ap_imp;
    int transitions = 0;

    `uvm_component_utils(alert_dut_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(alert_dut_item item);
        transitions++;
        `uvm_info(get_type_name(), $sformatf("[SCOREBOARD VERIFICATION] Alert Event #%0d: Confirmed alert_led = %0b at timestamp %0t ps", transitions, item.alert_val, item.alert_time), UVM_LOW)
    endfunction

endclass
