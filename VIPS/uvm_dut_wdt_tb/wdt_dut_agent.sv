// ==============================================================================
// Class: wdt_dut_agent
// Description: UVM Agent for WDT VIP
// ==============================================================================

class wdt_dut_agent extends uvm_agent;

    wdt_dut_sequencer seqr;
    wdt_dut_driver    drv;
    wdt_dut_monitor   mon;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    `uvm_component_utils_begin(wdt_dut_agent)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = wdt_dut_monitor::type_id::create("mon", this);
        if (is_active == UVM_ACTIVE) begin
            drv  = wdt_dut_driver::type_id::create("drv", this);
            seqr = wdt_dut_sequencer::type_id::create("seqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction

endclass
