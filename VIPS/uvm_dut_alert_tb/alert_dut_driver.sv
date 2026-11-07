// ==============================================================================
// Class: alert_dut_driver
// Description: UVM Driver for alert_dut (passive monitor support)
// ==============================================================================

class alert_dut_driver extends uvm_driver #(alert_dut_item);

    virtual alert_dut_if vif;

    `uvm_component_utils(alert_dut_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual alert_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'alert_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'alert_dut_if' in driver from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        // Alert is an autonomous output driven from SentinelSoC DUT
        @(posedge vif.rst_n);
    endtask

endclass
