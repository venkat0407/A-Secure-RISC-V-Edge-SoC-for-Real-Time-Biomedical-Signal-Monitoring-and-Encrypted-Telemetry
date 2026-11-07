class gpio_monitor extends uvm_monitor;
  virtual gpio_if vif;
  uvm_analysis_port #(gpio_item) ap;

  `uvm_component_utils(gpio_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual gpio_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'gpio_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    gpio_item item;
    @(posedge vif.rst_n);
    forever begin
      @(posedge vif.clk);
      item = gpio_item::type_id::create("item");
      item.gpio_io = vif.gpio_io;
      ap.write(item);
    end
  endtask
endclass
