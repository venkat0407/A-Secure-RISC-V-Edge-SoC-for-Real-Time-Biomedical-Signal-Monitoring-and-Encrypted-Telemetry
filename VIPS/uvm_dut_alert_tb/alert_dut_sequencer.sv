// ==============================================================================
// Class: alert_dut_sequencer
// Description: UVM Sequencer for Alert VIP
// ==============================================================================

class alert_dut_sequencer extends uvm_sequencer #(alert_dut_item);

    `uvm_component_utils(alert_dut_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
