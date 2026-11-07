// ==============================================================================
// Class: boundary_dut_sequence
// Description: UVM Sequence generating stimulus across multiple boundary domains
// ==============================================================================

class boundary_dut_sequence extends uvm_sequence #(boundary_dut_item);

    `uvm_object_utils(boundary_dut_sequence)

    function new(string name = "boundary_dut_sequence");
        super.new(name);
    endfunction

    task body();
        boundary_dut_item item;

        `uvm_info(get_type_name(), "=== Starting Unified Boundary Dynamic Stimulus Sequence ===", UVM_LOW)

        // 1. Send UART byte and drive GPIO inputs
        item = boundary_dut_item::type_id::create("item");
        start_item(item);
        item.uart_byte  = 8'h5A;
        item.gpio_en    = 8'hF0;
        item.gpio_data  = 8'hC0;
        item.adc_sample = 12'h850;
        finish_item(item);

        #1000ns;

        // 2. Drive next stimulus packet
        item = boundary_dut_item::type_id::create("item");
        start_item(item);
        item.uart_byte  = 8'hA5;
        item.gpio_en    = 8'hF0;
        item.gpio_data  = 8'h30;
        item.adc_sample = 12'h920;
        finish_item(item);

        #2000ns;
        `uvm_info(get_type_name(), "=== Unified Boundary Dynamic Stimulus Sequence Completed ===", UVM_LOW)
    endtask

endclass
