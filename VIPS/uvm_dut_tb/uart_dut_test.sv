// ==============================================================================
// Class: uart_dut_test
// Description: UVM Test coordinating dynamic VIP stimulus and DUT interface driving
// ==============================================================================

class uart_dut_test extends uvm_test;

    uart_dut_env env;

    `uvm_component_utils(uart_dut_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_dut_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        uart_dut_sequence seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting SentinelSoC DUT <-> UVM VIP Interconnect Test", UVM_LOW)
        `uvm_info(get_type_name(), "  1. VIP Driver drives uart_rx into DUT interface", UVM_LOW)
        `uvm_info(get_type_name(), "  2. DUT CPU writes to UART THR, driving uart_tx out to VIP Monitor", UVM_LOW)
        `uvm_info(get_type_name(), "================================================================", UVM_LOW)

        // Dynamically create and execute sequence
        seq = uart_dut_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);

        #5000ns;
        `uvm_info(get_type_name(), "=== SentinelSoC DUT <-> UVM VIP Verification Finished Successfully ===", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
