// ==============================================================================
// Class: uart_dut_monitor
// Description: UVM Monitor getting virtual interface from config_db and capturing
//              data driven out by the DUT interface (uart_tx)
// ==============================================================================

class uart_dut_monitor extends uvm_monitor;

    virtual uart_dut_if vif;
    uvm_analysis_port #(uart_dut_item) ap;
    int baud_cycles = 16;

    `uvm_component_utils(uart_dut_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Cookbook pattern: Get virtual interface from config_db
        if (!uvm_config_db#(virtual uart_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'uart_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'uart_dut_if' in monitor from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        uart_dut_item item;
        bit [7:0] sampled_byte;

        @(posedge vif.rst_n);

        forever begin
            // Detect start bit from DUT (falling edge on uart_tx)
            @(negedge vif.uart_tx);

            // Wait to center of start bit
            repeat (baud_cycles / 2) @(posedge vif.clk);

            if (vif.uart_tx == 1'b0) begin
                // Sample 8 data bits at mid-bit intervals
                for (int i = 0; i < 8; i++) begin
                    repeat (baud_cycles) @(posedge vif.clk);
                    sampled_byte[i] = vif.uart_tx;
                end

                // Wait for stop bit
                repeat (baud_cycles) @(posedge vif.clk);

                item = uart_dut_item::type_id::create("item");
                item.rx_data = sampled_byte;
                item.is_from_dut = 1'b1;

                `uvm_info(get_type_name(), $sformatf("[DUT INTERFACE -> VIP MONITOR] Captured byte driven by DUT: 0x%02h ('%c')", sampled_byte, sampled_byte), UVM_LOW)
                ap.write(item);
            end
        end
    endtask

endclass
