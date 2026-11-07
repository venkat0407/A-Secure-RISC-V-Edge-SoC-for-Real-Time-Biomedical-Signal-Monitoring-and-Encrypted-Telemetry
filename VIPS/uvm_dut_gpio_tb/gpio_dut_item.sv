// ==============================================================================
// Class: gpio_dut_item
// Description: UVM Sequence Item representing a GPIO transaction
// ==============================================================================

class gpio_dut_item extends uvm_sequence_item;

    rand bit [7:0] drive_data;
    rand bit [7:0] drive_en;
    bit [7:0]      sampled_data;
    bit            is_dut_output;

    `uvm_object_utils_begin(gpio_dut_item)
        `uvm_field_int(drive_data,    UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(drive_en,      UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(sampled_data,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(is_dut_output, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "gpio_dut_item");
        super.new(name);
    endfunction

endclass
