// ==============================================================================
// Class: uart_dut_sequence
// Description: UVM Sequence creating dynamic transaction items for driver
// ==============================================================================

class uart_dut_sequence extends uvm_sequence #(uart_dut_item);

    `uvm_object_utils(uart_dut_sequence)

    function new(string name = "uart_dut_sequence");
        super.new(name);
    endfunction

    task body();
        uart_dut_item item;
        byte test_payload[4] = '{8'h55, 8'hAA, 8'h48, 8'h49}; // 'U', 0xAA, 'H', 'I'

        `uvm_info(get_type_name(), "=== Starting Dynamic VIP Driving Sequence ===", UVM_LOW)

        for (int i = 0; i < 4; i++) begin
            item = uart_dut_item::type_id::create("item");
            start_item(item);
            item.tx_data = test_payload[i];
            item.is_from_dut = 1'b0;
            finish_item(item);
            #100ns;
        end

        `uvm_info(get_type_name(), "=== Dynamic VIP Driving Sequence Completed ===", UVM_LOW)
    endtask

endclass
