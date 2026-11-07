// ==============================================================================
// Class: wdt_dut_sequencer
// Description: UVM Sequencer for WDT VIP
// ==============================================================================

class wdt_dut_sequencer extends uvm_sequencer #(wdt_dut_item);

    `uvm_component_utils(wdt_dut_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
