// ==============================================================================
// Class: adc_dut_monitor
// Description: UVM Monitor sampling ADC input stream and broadcasting to scoreboard
// ==============================================================================

class adc_dut_monitor extends uvm_monitor;

    virtual adc_dut_if vif;
    uvm_analysis_port #(adc_dut_item) ap;

    `uvm_component_utils(adc_dut_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adc_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'adc_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'adc_dut_if' in monitor from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        adc_dut_item item;

        @(posedge vif.rst_n);
        forever begin
            @(posedge vif.clk);
            if (vif.adc_sample_valid === 1'b1) begin
                item = adc_dut_item::type_id::create("item");
                item.sample_data = vif.adc_sample_data;
                `uvm_info(get_type_name(), $sformatf("[DUT INTERFACE -> VIP MONITOR] Monitored ADC valid sample: 0x%03h", vif.adc_sample_data), UVM_LOW)
                ap.write(item);
            end
        end
    endtask

endclass
