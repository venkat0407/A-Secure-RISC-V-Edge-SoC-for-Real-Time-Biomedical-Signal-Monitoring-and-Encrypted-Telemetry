// ==============================================================================
// Class: boundary_dut_monitor
// Description: UVM Monitor sampling all boundary signals across domains
// ==============================================================================

class boundary_dut_monitor extends uvm_monitor;

    virtual boundary_dut_if vif;
    uvm_analysis_port #(boundary_dut_item) ap;

    `uvm_component_utils(boundary_dut_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual boundary_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'boundary_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'boundary_dut_if' in monitor from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        boundary_dut_item item;
        logic [7:0] prev_gpio = 8'hxx;
        logic       prev_irq  = 1'b0;

        @(posedge vif.rst_n);
        forever begin
            @(posedge vif.clk);
            if (vif.gpio_io !== prev_gpio || vif.core_irq_out !== prev_irq) begin
                prev_gpio = vif.gpio_io;
                prev_irq  = vif.core_irq_out;
                item = boundary_dut_item::type_id::create("item");
                item.gpio_sampled      = vif.gpio_io;
                item.irq_sampled       = vif.core_irq_out;
                item.alert_sampled     = vif.alert_led;
                item.wdt_reset_sampled = vif.wdt_reset_n;
                `uvm_info(get_type_name(), $sformatf("[DUT BOUNDARY -> VIP MONITOR] Sampled: gpio=0x%02h, irq=%0b, alert=%0b, wdt=%0b",
                    vif.gpio_io, vif.core_irq_out, vif.alert_led, vif.wdt_reset_n), UVM_LOW)
                ap.write(item);
            end
        end
    endtask

endclass
