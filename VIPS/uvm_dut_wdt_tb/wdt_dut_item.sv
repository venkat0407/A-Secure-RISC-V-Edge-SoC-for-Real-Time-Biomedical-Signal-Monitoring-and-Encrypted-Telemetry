// ==============================================================================
// Class: wdt_dut_item
// Description: UVM Sequence Item representing a Watchdog reset event
// ==============================================================================

class wdt_dut_item extends uvm_sequence_item;

    bit  wdt_reset_active;
    time transition_time;

    `uvm_object_utils_begin(wdt_dut_item)
        `uvm_field_int(wdt_reset_active, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(transition_time,  UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "wdt_dut_item");
        super.new(name);
    endfunction

endclass
