// ==============================================================================
// Class: wdt_dut_sequence
// Description: UVM Sequence for WDT VIP
// ==============================================================================

class wdt_dut_sequence extends uvm_sequence #(wdt_dut_item);

    `uvm_object_utils(wdt_dut_sequence)

    function new(string name = "wdt_dut_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "=== Starting WDT VIP Sequence: Supervising wdt_reset_n failsafe pin ===", UVM_LOW)
        #3000ns;
        `uvm_info(get_type_name(), "=== WDT VIP Sequence Completed ===", UVM_LOW)
    endtask

endclass
