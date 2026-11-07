// ==============================================================================
// Class: adc_dut_item
// Description: UVM Sequence Item representing an ADC sample transaction
// ==============================================================================

class adc_dut_item extends uvm_sequence_item;

    rand bit [11:0] sample_data;
    rand int        gap_cycles;

    constraint c_gap {
        gap_cycles inside {[2:8]};
    }

    constraint c_sample {
        sample_data inside {[12'h600:12'hB00]};
    }

    `uvm_object_utils_begin(adc_dut_item)
        `uvm_field_int(sample_data, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(gap_cycles,  UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "adc_dut_item");
        super.new(name);
    endfunction

endclass
