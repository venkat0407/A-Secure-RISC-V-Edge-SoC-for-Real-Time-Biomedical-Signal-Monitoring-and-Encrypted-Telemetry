class uart_monitor extends uvm_monitor;
  virtual uart_if vif;
  uvm_analysis_port #(uart_item) ap;

  `uvm_component_utils(uart_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'uart_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    uart_item item;
    @(posedge vif.rst_n);
    forever begin
      @(posedge vif.clk);
      item = uart_item::type_id::create("item");
      item.uart_rx = vif.uart_rx;
      item.uart_tx = vif.uart_tx;
      ap.write(item);
    end
  endtask
endclass
