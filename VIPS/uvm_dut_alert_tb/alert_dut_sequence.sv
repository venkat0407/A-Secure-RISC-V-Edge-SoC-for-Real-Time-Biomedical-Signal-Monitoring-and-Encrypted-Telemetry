// ==============================================================================
// Class: alert_dut_sequence
// Description: UVM Sequence for Alert VIP (monitoring supervision)
// ==============================================================================

class alert_dut_sequence extends uvm_sequence #(alert_dut_item);

    `uvm_object_utils(alert_dut_sequence)

    function new(string name = "alert_dut_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "=== Starting Alert VIP Sequence: Supervising autonomous alert_led pin ===", UVM_LOW)
        #2500ns;
        `uvm_info(get_type_name(), "=== Alert VIP Sequence Completed ===", UVM_LOW)
    endtask

endclass
