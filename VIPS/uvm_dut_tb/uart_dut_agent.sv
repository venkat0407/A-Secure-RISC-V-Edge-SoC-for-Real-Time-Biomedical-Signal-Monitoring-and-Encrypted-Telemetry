// ==============================================================================
// Class: uart_dut_agent
// Description: UVM Agent dynamically instantiating driver, monitor, and sequencer
// ==============================================================================

class uart_dut_agent extends uvm_agent;

    uart_dut_driver    drv;
    uart_dut_monitor   mon;
    uart_dut_sequencer seqr;

    `uvm_component_utils(uart_dut_agent)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Dynamic factory creation
        drv  = uart_dut_driver::type_id::create("drv", this);
        mon  = uart_dut_monitor::type_id::create("mon", this);
        seqr = uart_dut_sequencer::type_id::create("seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass
