// ==============================================================================
// Class: alert_dut_item
// Description: UVM Sequence Item representing an Alert LED transition event
// ==============================================================================

class alert_dut_item extends uvm_sequence_item;

    bit  alert_val;
    time alert_time;

    `uvm_object_utils_begin(alert_dut_item)
        `uvm_field_int(alert_val,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(alert_time, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "alert_dut_item");
        super.new(name);
    endfunction

endclass
