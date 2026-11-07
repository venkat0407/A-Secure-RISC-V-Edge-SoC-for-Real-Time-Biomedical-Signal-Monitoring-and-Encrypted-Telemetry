class adc_item extends uvm_sequence_item;

  rand bit [11:0] adc_sample_data;
  rand bit adc_sample_valid;

  `uvm_object_utils_begin(adc_item)
    `uvm_field_int(adc_sample_data, UVM_ALL_ON)
    `uvm_field_int(adc_sample_valid, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "adc_item");
    super.new(name);
  endfunction
endclass
