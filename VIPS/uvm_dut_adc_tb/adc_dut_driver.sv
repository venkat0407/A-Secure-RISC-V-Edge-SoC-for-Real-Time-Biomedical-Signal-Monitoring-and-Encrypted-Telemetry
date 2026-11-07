// ==============================================================================
// Class: adc_dut_driver
// Description: UVM Driver getting virtual interface from config_db and driving
//              ADC sample stream into SentinelSoC DUT
// ==============================================================================

class adc_dut_driver extends uvm_driver #(adc_dut_item);

    virtual adc_dut_if vif;

    `uvm_component_utils(adc_dut_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adc_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'adc_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'adc_dut_if' from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        vif.adc_sample_data  <= 12'h800;
        vif.adc_sample_valid <= 1'b0;
        @(posedge vif.rst_n);
        repeat (15) @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);

            repeat (req.gap_cycles) @(posedge vif.clk);

            vif.adc_sample_data  <= req.sample_data;
            vif.adc_sample_valid <= 1'b1;
            `uvm_info(get_type_name(), $sformatf("[VIP DRIVER -> DUT ADC] Driven sample 0x%03h with valid strobe", req.sample_data), UVM_LOW)

            @(posedge vif.clk);
            vif.adc_sample_valid <= 1'b0;

            seq_item_port.item_done();
        end
    endtask

endclass
