// ==============================================================================
// Class: irq_dut_monitor
// Description: UVM Monitor capturing core_irq_out assertions/deassertions from DUT
// ==============================================================================

class irq_dut_monitor extends uvm_monitor;

    virtual irq_dut_if vif;
    uvm_analysis_port #(irq_dut_item) ap;

    `uvm_component_utils(irq_dut_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual irq_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'irq_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'irq_dut_if' in monitor from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        irq_dut_item item;
        logic prev_val = 1'b0;

        @(posedge vif.rst_n);
        forever begin
            @(posedge vif.clk);
            if (vif.core_irq_out !== prev_val) begin
                prev_val = vif.core_irq_out;
                item = irq_dut_item::type_id::create("item");
                item.core_irq_active = vif.core_irq_out;
                item.transition_time = $time;
                `uvm_info(get_type_name(), $sformatf("[DUT INTERFACE -> VIP MONITOR] Core IRQ pin (core_irq_out) changed to %0b at %0t ps", vif.core_irq_out, $time), UVM_LOW)
                ap.write(item);
            end
        end
    endtask

endclass
