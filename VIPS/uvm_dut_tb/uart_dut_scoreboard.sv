// ==============================================================================
// Class: uart_dut_scoreboard
// Description: UVM Scoreboard checking and validating data transactions
// ==============================================================================

class uart_dut_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(uart_dut_item, uart_dut_scoreboard) ap_imp;
    int received_count = 0;

    `uvm_component_utils(uart_dut_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(uart_dut_item item);
        received_count++;
        `uvm_info(get_type_name(), $sformatf("[SCOREBOARD VERIFICATION] Received Item #%0d: DUT transmitted 0x%02h ('%c')", received_count, item.rx_data, item.rx_data), UVM_LOW)
    endfunction

endclass
