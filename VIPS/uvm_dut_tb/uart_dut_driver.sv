// ==============================================================================
// Class: uart_dut_driver
// Description: UVM Driver getting virtual interface from config_db and driving
//              stimulus into DUT interface
// ==============================================================================

class uart_dut_driver extends uvm_driver #(uart_dut_item);

    virtual uart_dut_if vif;
    int baud_cycles = 16; // Cycles per bit for simulation

    `uvm_component_utils(uart_dut_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Cookbook pattern: Get virtual interface handle from UVM configuration database
        if (!uvm_config_db#(virtual uart_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'uart_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'uart_dut_if' from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        // Default idle line is high (1'b1)
        vif.uart_rx <= 1'b1;
        @(posedge vif.rst_n);
        repeat (20) @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);

            `uvm_info(get_type_name(), $sformatf("[VIP DRIVER -> DUT INTERFACE] Driving byte 0x%02h ('%c') onto vif.uart_rx", req.tx_data, req.tx_data), UVM_LOW)

            // 1. Start bit: pull low (0)
            vif.uart_rx <= 1'b0;
            repeat (baud_cycles) @(posedge vif.clk);

            // 2. 8 Data bits (LSB first)
            for (int b = 0; b < 8; b++) begin
                vif.uart_rx <= req.tx_data[b];
                repeat (baud_cycles) @(posedge vif.clk);
            end

            // 3. Stop bit: return to high (1)
            vif.uart_rx <= 1'b1;
            repeat (baud_cycles) @(posedge vif.clk);

            `uvm_info(get_type_name(), $sformatf("[VIP DRIVER -> DUT INTERFACE] Transmission of byte 0x%02h complete", req.tx_data), UVM_MEDIUM)
            seq_item_port.item_done();
        end
    endtask

endclass
