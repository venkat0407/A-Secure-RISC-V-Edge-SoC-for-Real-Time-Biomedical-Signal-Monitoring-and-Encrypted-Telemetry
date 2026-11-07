class gpio_base_sequence extends uvm_sequence #(gpio_item);
  `uvm_object_utils(gpio_base_sequence)

  function new(string name = "gpio_base_sequence");
    super.new(name);
  endfunction

  task body();
    gpio_item req_item;
    repeat (5) begin
      req_item = gpio_item::type_id::create("req_item");
      start_item(req_item);
      if (!req_item.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      finish_item(req_item);
      #20ns;
    end
  endtask
endclass
