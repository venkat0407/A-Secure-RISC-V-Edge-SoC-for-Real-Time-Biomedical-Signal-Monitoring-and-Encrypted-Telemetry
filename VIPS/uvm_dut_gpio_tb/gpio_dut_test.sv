// ==============================================================================
// Class: gpio_dut_test
// Description: UVM Test controlling GPIO VIP sequence and synchronization
// ==============================================================================

class gpio_dut_test extends uvm_test;

    gpio_dut_env env;

    `uvm_component_utils(gpio_dut_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = gpio_dut_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        gpio_dut_sequence seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting SentinelSoC DUT <-> GPIO UVM VIP Interconnect Test", UVM_LOW)
        `uvm_info(get_type_name(), "  1. DUT CPU configures lower 4 bits as output and drives 0x0A, 0x05", UVM_LOW)
        `uvm_info(get_type_name(), "  2. VIP Driver drives upper 4 bits as external inputs into DUT", UVM_LOW)
        `uvm_info(get_type_name(), "  3. VIP Monitor samples all bidirectional transactions on gpio_io", UVM_LOW)
        `uvm_info(get_type_name(), "================================================================", UVM_LOW)

        seq = gpio_dut_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);

        #5000ns;
        `uvm_info(get_type_name(), "=== SentinelSoC DUT <-> GPIO UVM VIP Verification Finished Successfully ===", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
