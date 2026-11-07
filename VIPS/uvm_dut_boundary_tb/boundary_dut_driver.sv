// ==============================================================================
// Class: boundary_dut_driver
// Description: UVM Driver applying concurrent stimulus onto DUT boundary interface
// ==============================================================================

class boundary_dut_driver extends uvm_driver #(boundary_dut_item);

    virtual boundary_dut_if vif;
    int baud_cycles = 16;

    `uvm_component_utils(boundary_dut_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual boundary_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'boundary_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'boundary_dut_if' from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        vif.uart_rx          <= 1'b1;
        vif.gpio_drv_en      <= 8'h00;
        vif.gpio_drv_data    <= 8'h00;
        vif.adc_sample_data  <= 12'h800;
        vif.adc_sample_valid <= 1'b0;

        @(posedge vif.rst_n);
        repeat (15) @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);

            // 1. Drive GPIO
            vif.gpio_drv_en   <= req.gpio_en;
            vif.gpio_drv_data <= req.gpio_data;

            // 2. Drive ADC sample
            vif.adc_sample_data  <= req.adc_sample;
            vif.adc_sample_valid <= 1'b1;
            @(posedge vif.clk);
            vif.adc_sample_valid <= 1'b0;

            // 3. Drive UART bitstream
            vif.uart_rx <= 1'b0; // start bit
            repeat (baud_cycles) @(posedge vif.clk);
            for (int b = 0; b < 8; b++) begin
                vif.uart_rx <= req.uart_byte[b];
                repeat (baud_cycles) @(posedge vif.clk);
            end
            vif.uart_rx <= 1'b1; // stop bit
            repeat (baud_cycles) @(posedge vif.clk);

            seq_item_port.item_done();
        end
    endtask

endclass
