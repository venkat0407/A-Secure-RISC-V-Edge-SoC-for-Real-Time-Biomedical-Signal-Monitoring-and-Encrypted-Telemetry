// ==============================================================================
// Class: irq_dut_driver
// Description: UVM Driver for IRQ VIP
// ==============================================================================

class irq_dut_driver extends uvm_driver #(irq_dut_item);

    virtual irq_dut_if vif;

    `uvm_component_utils(irq_dut_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual irq_dut_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface 'irq_dut_if' not found in config_db for %s", get_full_name()))
        end
        `uvm_info(get_type_name(), "Successfully retrieved virtual interface 'irq_dut_if' from uvm_config_db using GET!", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        @(posedge vif.rst_n);
    endtask

endclass
