// ==============================================================================
// Class: gpio_dut_sequence
// Description: UVM Sequence creating dynamic GPIO transactions
// ==============================================================================

class gpio_dut_sequence extends uvm_sequence #(gpio_dut_item);

    `uvm_object_utils(gpio_dut_sequence)

    function new(string name = "gpio_dut_sequence");
        super.new(name);
    endfunction

    task body();
        gpio_dut_item item;

        `uvm_info(get_type_name(), "=== Starting Dynamic VIP GPIO Sequence ===", UVM_LOW)

        // VIP drives upper 4 bits as inputs into DUT (drive_en = 0xF0)
        item = gpio_dut_item::type_id::create("item");
        start_item(item);
        item.drive_en   = 8'hF0;
        item.drive_data = 8'hA0; // upper nibble = 0xA
        finish_item(item);

        #1500ns;

        item = gpio_dut_item::type_id::create("item");
        start_item(item);
        item.drive_en   = 8'hF0;
        item.drive_data = 8'h50; // upper nibble = 0x5
        finish_item(item);

        #1500ns;
        `uvm_info(get_type_name(), "=== Dynamic VIP GPIO Sequence Completed ===", UVM_LOW)
    endtask

endclass
