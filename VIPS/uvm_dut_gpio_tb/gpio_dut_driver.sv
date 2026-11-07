// ==============================================================================
// Class: gpio_dut_driver
// Description: UVM Driver getting virtual interface from config_db and driving
//              stimulus into DUT interface
// ==============================================================================

class gpio_dut_driver extends uvm_driver #(gpio_dut_item);

    virtual gpio_dut_if vif;

    `uvm_component_utils(gpio_dut_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual gpio_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'gpio_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'gpio_dut_if' from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        vif.drv_en   <= 8'h00;
        vif.drv_data <= 8'h00;
        @(posedge vif.rst_n);
        repeat (10) @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);
            @(posedge vif.clk);
            vif.drv_en   <= req.drive_en;
            vif.drv_data <= req.drive_data;
            `uvm_info(get_type_name(), $sformatf("[VIP DRIVER -> DUT GPIO] Driving en=0x%02h, data=0x%02h onto gpio_io", req.drive_en, req.drive_data), UVM_LOW)
            repeat (20) @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask

endclass
