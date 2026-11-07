// ==============================================================================
// Class: boundary_dut_item
// Description: UVM Sequence Item representing Unified Boundary events
// ==============================================================================

class boundary_dut_item extends uvm_sequence_item;

    rand bit [7:0]  uart_byte;
    rand bit [7:0]  gpio_data;
    rand bit [7:0]  gpio_en;
    rand bit [11:0] adc_sample;

    bit             uart_tx_sampled;
    bit [7:0]       gpio_sampled;
    bit             alert_sampled;
    bit             wdt_reset_sampled;
    bit             irq_sampled;

    `uvm_object_utils_begin(boundary_dut_item)
        `uvm_field_int(uart_byte,         UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(gpio_data,         UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(gpio_en,           UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(adc_sample,        UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(gpio_sampled,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(alert_sampled,     UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(wdt_reset_sampled, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(irq_sampled,       UVM_ALL_ON | UVM_BIN)
    `uvm_object_utils_end

    function new(string name = "boundary_dut_item");
        super.new(name);
    endfunction

endclass
