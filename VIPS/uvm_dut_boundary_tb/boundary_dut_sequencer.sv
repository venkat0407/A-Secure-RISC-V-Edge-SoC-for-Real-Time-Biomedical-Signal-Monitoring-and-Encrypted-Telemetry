// ==============================================================================
// Class: boundary_dut_sequencer
// Description: UVM Sequencer for Unified Boundary VIP
// ==============================================================================

class boundary_dut_sequencer extends uvm_sequencer #(boundary_dut_item);

    `uvm_component_utils(boundary_dut_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
