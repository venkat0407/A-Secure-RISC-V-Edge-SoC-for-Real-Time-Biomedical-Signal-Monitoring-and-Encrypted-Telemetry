class irq_base_sequence extends uvm_sequence #(irq_item);
  `uvm_object_utils(irq_base_sequence)

  function new(string name = "irq_base_sequence");
    super.new(name);
  endfunction

  task body();
    irq_item req_item;
    repeat (5) begin
      req_item = irq_item::type_id::create("req_item");
      start_item(req_item);
      if (!req_item.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      finish_item(req_item);
      #20ns;
    end
  endtask
endclass
