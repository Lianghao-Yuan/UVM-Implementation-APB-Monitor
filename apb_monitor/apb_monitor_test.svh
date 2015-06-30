//
//  Module: APB3 monitor test (just a dummy test)
//  Author: Lianghao Yuan
//  Email: yuanlianghao@gmail.com
//  Date: 06/29/2015
//  Copyright (C) 2015 Lianghao Yuan

// ***********************************************************************
//  Notice: Since this is a very simple test, we do not create sequencer
//  or sequence_item for it. Instead we put the whole stimulus into this 
//  test. This is NOT recommended.
//  **********************************************************************
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//

`ifndef APB_MONITOR_TEST_SVH
`define APB_MONITOR_TEST_SVH

class apb_monitor_test extends uvm_test;
`uvm_component_utils(apb_monitor_test)
// -----------------------------
// Member components
//------------------------------
apb_monitor_env m_env;

// Virtual interface
// Since we initiate the stimulus here, we need to manipulate 
// the interface.
virtual apb_if apb_intf;
// -----------------------------
// Data member 
// -----------------------------
// For stimulus generation purpose
bit [15:0] PSEL_v;
// -----------------------------
// Methods
// -----------------------------
function new(string name = "apb_monitor_test", uvm_component parent = null);
  super.new(name, parent);
endfunction: new

function void build_phase(uvm_phase phase);
  // The virtual apb_if has been passed in by apb_tb
  m_env = apb_monitor_env::type_id::create("m_env", this);
  // We also need to have a apb_if handle for ourselves
  if(!uvm_config_db # (virtual apb_if)::get(this, "", "apb_intf", apb_intf)) begin
    `uvm_error("build_phase", "Unable to find apb_intf from uvm_config_db")
  end
endfunction: build_phase

// Stimulus generation
extern task run_phase(uvm_phase phase);
// Stimulus related tasks
extern task apb_park();
extern task apb_write(bit [15:0] PSEL_v);
extern task apb_read(bit [15:0] PSEL_v);

endclass: apb_monitor_test

// -----------------------------------------
// Extern methods
// -----------------------------------------

// Stimulus generation
task apb_monitor_test::run_phase(uvm_phase phase);
  phase.raise_objection(this);

  apb_intf.PSEL = 0;
  apb_park;
  repeat(10) begin
    // Write operation for all slaves
    PSEL_v = 16'h1;
    repeat(16) begin
      apb_read(PSEL_v);
      apb_park;
      PSEL_v = PSEL_v << 1;
    end
    // Read operation for all slaves
    PSEL_v = 16'h1;
    repeat(16) begin
      apb_write(PSEL_v);
      apb_park;
      PSEL_v = PSEL_v << 1;
    end
  end
  // If failed

  if(m_env.m_apb_monitor_cov.apb_protocol_cg.get_coverage() != 100) begin
      `uvm_info("run_phase", "[FAILED]: Coverage NOT achieved 100%", UVM_HIGH)
  end
  else begin
  // If successful
    `uvm_info("run_phase", "[PASSED]: 100% monitor coverage ACHIEVED", UVM_HIGH)
  end

  phase.drop_objection(this);
endtask: run_phase

// APB park task: put the bus into safe state
task apb_monitor_test::apb_park();
  @(posedge apb_intf.PCLK);
	apb_intf.PADDR <= 0;
  apb_intf.PWRITE <= 0;
  apb_intf.PSEL <= 0;
  apb_intf.PENABLE <= 0;
  apb_intf.PREADY <= 0;
  apb_intf.PSLVERR <= 0;
endtask: apb_park

// APB write task: including responses
task apb_monitor_test::apb_write(bit [15:0] PSEL_v);
  int response_delay;

  wait(apb_intf.PRESETn == 1); // Wait if in reset
  @(posedge apb_intf.PCLK);
  apb_intf.PSEL <= PSEL_v;
  apb_intf.PADDR <= $urandom();
  apb_intf.PWRITE <= 1; // Write
  apb_intf.PWDATA <= $urandom();
  @(posedge apb_intf.PCLK);
  apb_intf.PENABLE <= 1;
  // insert random wait state length
  response_delay = $urandom_range(0, 10);
  repeat(response_delay) begin
    @(posedge apb_intf.PCLK);
  end
  // Generate response
  apb_intf.PREADY <= 1;
  randcase
    1: apb_intf.PSLVERR <= 0;
    1: apb_intf.PSLVERR <= 1;
  endcase
  // End the transaction
  @(posedge apb_intf.PCLK);
  apb_intf.PREADY <= 0;
  apb_intf.PENABLE <= 0;
  apb_intf.PWRITE <= 0;
endtask: apb_write

// APB read task: including responses
task apb_monitor_test::apb_read(bit [15:0] PSEL_v);
  int response_delay;

  wait(apb_intf.PRESETn == 1);
  @(posedge apb_intf.PCLK);
  apb_intf.PSEL <= PSEL_v;
  apb_intf.PADDR <= $urandom();
  apb_intf.PWRITE <= 0; // Read
  @(posedge apb_intf.PCLK);
  apb_intf.PENABLE <= 1;
  // insert random wait state length
  response_delay = $urandom_range(0, 10);
  repeat(response_delay) begin
    @(posedge apb_intf.PCLK);
  end
  // Generate response
  apb_intf.PREADY <= 1;
  apb_intf.PRDATA <= $urandom();
  randcase
    1: apb_intf.PSLVERR <= 0;
    1: apb_intf.PSLVERR <= 1;
  endcase
  // End the transaction
  @(posedge apb_intf.PCLK);
  apb_intf.PREADY <= 0;
  apb_intf.PENABLE <= 0;
endtask: apb_read



`endif // APB_MONITOR_TEST_SVH

