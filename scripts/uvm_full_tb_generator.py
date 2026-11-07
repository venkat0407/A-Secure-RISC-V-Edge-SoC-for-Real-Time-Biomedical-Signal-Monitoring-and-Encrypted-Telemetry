#!/usr/bin/env python3
"""
UVM Testbench & VIP Generator (Cookbook-Compliant)
Usage:
  python uvm_full_tb_generator.py <vip_name> <signals.csv>

Supports CSV formats with or without header:
signal_name,direction,width
uart_rx,input,1
uart_tx,output,1
"""

import csv
import os
import sys

if len(sys.argv) < 3:
    print('Usage: python uvm_full_tb_generator.py <vip_name> <signals.csv>')
    sys.exit(1)

VIP = sys.argv[1].lower()
CSV_FILE = sys.argv[2]

CLK_NAMES = ['clk', 'clock', 'aclk']
RST_NAMES = ['rst', 'rst_n', 'reset', 'reset_n', 'aresetn']


def read_signals(csv_file):
    sigs = []
    with open(csv_file, 'r') as f:
        for row in csv.reader(f):
            if not row or len(row) < 3:
                continue
            name = row[0].strip()
            direction = row[1].strip().lower()
            width_str = row[2].strip()
            # Skip comment or header rows
            if name.startswith('#') or not width_str.isdigit():
                continue
            sigs.append({
                'name': name,
                'dir': direction,
                'width': int(width_str)
            })
    return sigs


def sv_type(width):
    return 'bit' if width == 1 else f'bit [{width-1}:0]'


def interface(signals):
    s = f"interface {VIP}_if(input logic clk, input logic rst_n);\n"
    s += "  // Boundary Signals\n"
    for sig in signals:
        if sig['name'] not in CLK_NAMES + RST_NAMES:
            if sig['width'] == 1:
                s += f"  logic {sig['name']};\n"
            else:
                s += f"  logic [{sig['width']-1}:0] {sig['name']};\n"
    s += "\n  // Modport for Driver / BFM\n"
    s += "  modport drv_mp (\n"
    s += "    input  clk, rst_n"
    for sig in signals:
        if sig['name'] not in CLK_NAMES + RST_NAMES:
            d = "output" if sig['dir'] in ['input', 'inout'] else "input"
            s += f",\n    {d} {sig['name']}"
    s += "\n  );\n"
    s += "\n  // Modport for Monitor\n"
    s += "  modport mon_mp (\n"
    s += "    input clk, rst_n"
    for sig in signals:
        if sig['name'] not in CLK_NAMES + RST_NAMES:
            s += f",\n    input {sig['name']}"
    s += "\n  );\n"
    s += "endinterface\n"
    return s


def transaction(signals):
    s = f"class {VIP}_item extends uvm_sequence_item;\n\n"
    for sig in signals:
        if sig['name'] not in CLK_NAMES + RST_NAMES:
            rand = 'rand ' if sig['dir'] in ['input', 'inout'] else ''
            s += f"  {rand}{sv_type(sig['width'])} {sig['name']};\n"
    s += f"\n  `uvm_object_utils_begin({VIP}_item)\n"
    for sig in signals:
        if sig['name'] not in CLK_NAMES + RST_NAMES:
            s += f"    `uvm_field_int({sig['name']}, UVM_ALL_ON)\n"
    s += "  `uvm_object_utils_end\n\n"
    s += f"  function new(string name = \"{VIP}_item\");\n"
    s += "    super.new(name);\n"
    s += "  endfunction\n"
    s += "endclass\n"
    return s


def sequencer():
    return f"""class {VIP}_sequencer extends uvm_sequencer #({VIP}_item);
  `uvm_component_utils({VIP}_sequencer)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
"""


def driver(signals):
    s = f"""class {VIP}_driver extends uvm_driver #({VIP}_item);
  virtual {VIP}_if vif;

  `uvm_component_utils({VIP}_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual {VIP}_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface '{VIP}_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    // Initialize driven outputs
    @(posedge vif.rst_n);
    forever begin
      seq_item_port.get_next_item(req);
      @(posedge vif.clk);
"""
    for sig in signals:
        if sig['name'] not in CLK_NAMES + RST_NAMES and sig['dir'] in ['input', 'inout']:
            s += f"      vif.{sig['name']} <= req.{sig['name']};\n"
    s += """      seq_item_port.item_done();
    end
  endtask
endclass
"""
    return s


def monitor(signals):
    s = f"""class {VIP}_monitor extends uvm_monitor;
  virtual {VIP}_if vif;
  uvm_analysis_port #({VIP}_item) ap;

  `uvm_component_utils({VIP}_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual {VIP}_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface '{VIP}_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    {VIP}_item item;
    @(posedge vif.rst_n);
    forever begin
      @(posedge vif.clk);
      item = {VIP}_item::type_id::create("item");
"""
    for sig in signals:
        if sig['name'] not in CLK_NAMES + RST_NAMES:
            s += f"      item.{sig['name']} = vif.{sig['name']};\n"
    s += """      ap.write(item);
    end
  endtask
endclass
"""
    return s


def agent():
    return f"""class {VIP}_agent extends uvm_agent;
  {VIP}_driver    drv;
  {VIP}_monitor   mon;
  {VIP}_sequencer seqr;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  `uvm_component_utils_begin({VIP}_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = {VIP}_monitor::type_id::create("mon", this);
    if (is_active == UVM_ACTIVE) begin
      drv  = {VIP}_driver::type_id::create("drv", this);
      seqr = {VIP}_sequencer::type_id::create("seqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass
"""


def scoreboard():
    return f"""class {VIP}_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #({VIP}_item, {VIP}_scoreboard) ap_imp;

  `uvm_component_utils({VIP}_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap_imp = new("ap_imp", this);
  endfunction

  function void write({VIP}_item item);
    `uvm_info(get_type_name(), $sformatf("Received item: %s", item.sprint()), UVM_HIGH)
  endfunction
endclass
"""


def sequence():
    return f"""class {VIP}_base_sequence extends uvm_sequence #({VIP}_item);
  `uvm_object_utils({VIP}_base_sequence)

  function new(string name = "{VIP}_base_sequence");
    super.new(name);
  endfunction

  task body();
    {VIP}_item req_item;
    repeat (5) begin
      req_item = {VIP}_item::type_id::create("req_item");
      start_item(req_item);
      if (!req_item.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      finish_item(req_item);
      #20ns;
    end
  endtask
endclass
"""


def env():
    return f"""class {VIP}_env extends uvm_env;
  {VIP}_agent      agent;
  {VIP}_scoreboard sb;

  `uvm_component_utils({VIP}_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = {VIP}_agent::type_id::create("agent", this);
    sb    = {VIP}_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon.ap.connect(sb.ap_imp);
  endfunction
endclass
"""


def test():
    return f"""class {VIP}_test extends uvm_test;
  {VIP}_env env;

  `uvm_component_utils({VIP}_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = {VIP}_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    {VIP}_base_sequence seq;
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "=== Starting {VIP.upper()} UVM Verification Sequence ===", UVM_LOW)
    seq = {VIP}_base_sequence::type_id::create("seq");
    seq.start(env.agent.seqr);
    #100ns;
    `uvm_info(get_type_name(), "=== {VIP.upper()} Sequence Finished Successfully ===", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
"""


def package():
    return f"""package {VIP}_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "{VIP}_item.sv"
  `include "{VIP}_sequencer.sv"
  `include "{VIP}_base_sequence.sv"
  `include "{VIP}_driver.sv"
  `include "{VIP}_monitor.sv"
  `include "{VIP}_agent.sv"
  `include "{VIP}_scoreboard.sv"
  `include "{VIP}_env.sv"
  `include "{VIP}_test.sv"
endpackage
"""


def tb_top():
    return f"""`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  import {VIP}_pkg::*;

  logic clk;
  logic rst_n;

  // Clock Generation (50 MHz)
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  // Reset Generation
  initial begin
    rst_n = 0;
    #40 rst_n = 1;
  end

  // Persistent VIP Interface (alive throughout simulation)
  {VIP}_if vif(clk, rst_n);

  initial begin
    // Register interface in UVM config_db using standard Cookbook pattern
    uvm_config_db#(virtual {VIP}_if)::set(null, "*", "vif", vif);

    // Run test
    run_test("{VIP}_test");
  end
endmodule
"""


def main():
    signals = read_signals(CSV_FILE)
    if not signals:
        print(f"Error: No signals read from {CSV_FILE}")
        sys.exit(1)

    outdir = f'{VIP}_uvm_tb'
    os.makedirs(outdir, exist_ok=True)

    files = {
        f'{VIP}_if.sv': interface(signals),
        f'{VIP}_item.sv': transaction(signals),
        f'{VIP}_sequencer.sv': sequencer(),
        f'{VIP}_base_sequence.sv': sequence(),
        f'{VIP}_driver.sv': driver(signals),
        f'{VIP}_monitor.sv': monitor(signals),
        f'{VIP}_agent.sv': agent(),
        f'{VIP}_scoreboard.sv': scoreboard(),
        f'{VIP}_env.sv': env(),
        f'{VIP}_test.sv': test(),
        f'{VIP}_pkg.sv': package(),
        'tb_top.sv': tb_top()
    }

    for name, content in files.items():
        with open(os.path.join(outdir, name), 'w') as f:
            f.write(content)

    print(f"Generated {len(files)} UVM files in: {outdir}")


if __name__ == '__main__':
    main()
