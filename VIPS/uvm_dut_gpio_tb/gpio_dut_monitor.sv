// ==============================================================================
// Class: gpio_dut_monitor
// Description: UVM Monitor observing GPIO bus and broadcasting to scoreboard
// ==============================================================================

class gpio_dut_monitor extends uvm_monitor;

    virtual gpio_dut_if vif;
    uvm_analysis_port #(gpio_dut_item) ap;

    `uvm_component_utils(gpio_dut_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual gpio_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'gpio_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'gpio_dut_if' in monitor from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        logic [7:0] prev_val = 8'hxx;
        gpio_dut_item item;

        @(posedge vif.rst_n);
        forever begin
            @(posedge vif.clk);
            if (vif.gpio_io !== prev_val) begin
                prev_val = vif.gpio_io;
                item = gpio_dut_item::type_id::create("item");
                item.sampled_data = vif.gpio_io;
                `uvm_info(get_type_name(), $sformatf("[DUT INTERFACE -> VIP MONITOR] Captured GPIO change: gpio_io = 0x%02h (b%08b)", vif.gpio_io, vif.gpio_io), UVM_LOW)
                ap.write(item);
            end
        end
    endtask

endclass
