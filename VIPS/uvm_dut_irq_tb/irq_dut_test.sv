// ==============================================================================
// Class: irq_dut_test
// Description: UVM Test orchestrating interrupt generation, routing, and W1C clear
// ==============================================================================

class irq_dut_test extends uvm_test;

    irq_dut_env env;

    `uvm_component_utils(irq_dut_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = irq_dut_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        irq_dut_sequence seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting SentinelSoC DUT <-> IRQ UVM VIP Test", UVM_LOW)
        `uvm_info(get_type_name(), "  1. DUT CPU unmasks interrupt aggregator sources (0x1000_8004)", UVM_LOW)
        `uvm_info(get_type_name(), "  2. DUT Timer fires expiration compare match, asserting IRQ", UVM_LOW)
        `uvm_info(get_type_name(), "  3. VIP Monitor captures core_irq_out assertion", UVM_LOW)
        `uvm_info(get_type_name(), "  4. DUT CPU clears cause bit via W1C, deasserting core_irq_out", UVM_LOW)
        `uvm_info(get_type_name(), "================================================================", UVM_LOW)

        seq = irq_dut_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);

        #4000ns;
        `uvm_info(get_type_name(), "=== SentinelSoC DUT <-> IRQ UVM VIP Verification Finished Successfully ===", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
