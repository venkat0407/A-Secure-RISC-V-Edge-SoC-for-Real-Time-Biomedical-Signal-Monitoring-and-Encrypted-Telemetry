// ==============================================================================
// Class: alert_dut_monitor
// Description: UVM Monitor capturing autonomous alert_led assertion from DUT
// ==============================================================================

class alert_dut_monitor extends uvm_monitor;

    virtual alert_dut_if vif;
    uvm_analysis_port #(alert_dut_item) ap;

    `uvm_component_utils(alert_dut_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual alert_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'alert_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'alert_dut_if' in monitor from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        alert_dut_item item;
        logic prev_val = 1'b0;

        @(posedge vif.rst_n);
        forever begin
            @(posedge vif.clk);
            if (vif.alert_led !== prev_val) begin
                prev_val = vif.alert_led;
                item = alert_dut_item::type_id::create("item");
                item.alert_val  = vif.alert_led;
                item.alert_time = $time;
                `uvm_info(get_type_name(), $sformatf("[DUT INTERFACE -> VIP MONITOR] Autonomous Alert LED transitioned to %0b at %0t ps", vif.alert_led, $time), UVM_LOW)
                ap.write(item);
            end
        end
    endtask

endclass
