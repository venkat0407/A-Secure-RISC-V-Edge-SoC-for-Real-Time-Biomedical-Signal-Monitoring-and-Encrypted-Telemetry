// ==============================================================================
// Class: adc_dut_sequence
// Description: UVM Sequence creating ECG samples for ADC interface
// ==============================================================================

class adc_dut_sequence extends uvm_sequence #(adc_dut_item);

    `uvm_object_utils(adc_dut_sequence)

    function new(string name = "adc_dut_sequence");
        super.new(name);
    endfunction

    task body();
        adc_dut_item item;
        // Sample ECG points: Baseline (0x800), P-wave, Q-dip, R-peak (0xA50), S-dip, T-wave
        bit [11:0] ecg_samples[6] = '{12'h800, 12'h850, 12'h7A0, 12'hA50, 12'h700, 12'h880};

        `uvm_info(get_type_name(), "=== Starting Dynamic VIP ADC Sampling Sequence ===", UVM_LOW)

        for (int i = 0; i < 6; i++) begin
            item = adc_dut_item::type_id::create("item");
            start_item(item);
            item.sample_data = ecg_samples[i];
            item.gap_cycles  = 4;
            finish_item(item);
            #150ns;
        end

        `uvm_info(get_type_name(), "=== Dynamic VIP ADC Sampling Sequence Completed ===", UVM_LOW)
    endtask

endclass
