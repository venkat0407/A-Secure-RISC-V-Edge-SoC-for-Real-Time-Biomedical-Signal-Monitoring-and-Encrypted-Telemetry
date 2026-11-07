// ==============================================================================
// Class: boundary_dut_test
// Description: UVM Test for Unified SentinelSoC Boundary Verification
// ==============================================================================

class boundary_dut_test extends uvm_test;

    boundary_dut_env env;

    `uvm_component_utils(boundary_dut_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = boundary_dut_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        boundary_dut_sequence seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting SentinelSoC DUT <-> Unified Boundary UVM VIP Test", UVM_LOW)
        `uvm_info(get_type_name(), "  Simultaneously verifying UART, GPIO, ADC, WDT, Alert, and IRQ", UVM_LOW)
        `uvm_info(get_type_name(), "================================================================", UVM_LOW)

        seq = boundary_dut_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);

        #5000ns;
        `uvm_info(get_type_name(), "=== SentinelSoC DUT <-> Unified Boundary UVM VIP Finished Successfully ===", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
