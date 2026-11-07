class adc_base_sequence extends uvm_sequence #(adc_item);
  `uvm_object_utils(adc_base_sequence)

  function new(string name = "adc_base_sequence");
    super.new(name);
  endfunction

  task body();
    adc_item req_item;
    repeat (5) begin
      req_item = adc_item::type_id::create("req_item");
      start_item(req_item);
      if (!req_item.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      finish_item(req_item);
      #20ns;
    end
  endtask
endclass
