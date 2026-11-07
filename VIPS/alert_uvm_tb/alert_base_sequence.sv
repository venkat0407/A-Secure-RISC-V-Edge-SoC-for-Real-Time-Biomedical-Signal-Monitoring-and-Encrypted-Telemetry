class alert_base_sequence extends uvm_sequence #(alert_item);
  `uvm_object_utils(alert_base_sequence)

  function new(string name = "alert_base_sequence");
    super.new(name);
  endfunction

  task body();
    alert_item req_item;
    repeat (5) begin
      req_item = alert_item::type_id::create("req_item");
      start_item(req_item);
      if (!req_item.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      finish_item(req_item);
      #20ns;
    end
  endtask
endclass
