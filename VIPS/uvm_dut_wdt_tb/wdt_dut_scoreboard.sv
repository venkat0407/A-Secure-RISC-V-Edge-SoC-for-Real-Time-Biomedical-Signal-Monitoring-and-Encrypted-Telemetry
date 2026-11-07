// ==============================================================================
// Class: wdt_dut_scoreboard
// Description: UVM Scoreboard verifying Watchdog reset pulses
// ==============================================================================

class wdt_dut_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(wdt_dut_item, wdt_dut_scoreboard) ap_imp;
    int events = 0;

    `uvm_component_utils(wdt_dut_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(wdt_dut_item item);
        events++;
        `uvm_info(get_type_name(), $sformatf("[SCOREBOARD VERIFICATION] WDT Event #%0d: Observed wdt_reset_n active=%0b at timestamp %0t ps", events, item.wdt_reset_active, item.transition_time), UVM_LOW)
    endfunction

endclass
