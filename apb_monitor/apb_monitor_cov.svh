//
//  Module: APB3 monitor coverage
//  Author: Lianghao Yuan
//  Email: yuanlianghao@gmail.com
//  Date: 06/30/2015
//  Copyright (C) 2015 Lianghao Yuan

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
`ifndef APB_MONITOR_COV_SV
`define APB_MONITOR_COV_SV

class apb_monitor_cov extends uvm_component;
// UVM factory registration macro
`uvm_component_utils(apb_monitor_cov)

// Virtual interface
virtual apb_if apb_intf;

// -------------------------------------------------------
// Coverage group
// -------------------------------------------------------
// Functional Coverage for the APB transfers:
//
// Have we seen all possible PSELS activated?
// Have we seen reads/writes to all slaves?
// Have we seen good and bad PSLVERR results from all slaves?
covergroup apb_protocol_cg();

	option.per_instance = 1;

	RW: coverpoint apb_intf.PWRITE {
		bins read = {0};
		bins write = {1};
	}
	ERR: coverpoint apb_intf.PSLVERR {
		bins err = {1};
		bins ok = {0};
	}
  PSEL: coverpoint apb_intf.PSEL {
    bins PSEL_0 = {16'b1 << 0};
    bins PSEL_1 = {16'b1 << 1};
    bins PSEL_2 = {16'b1 << 2};
    bins PSEL_3 = {16'b1 << 3};
    bins PSEL_4 = {16'b1 << 4};
    bins PSEL_5 = {16'b1 << 5};
    bins PSEL_6 = {16'b1 << 6};
    bins PSEL_7 = {16'b1 << 7};
    bins PSEL_8 = {16'b1 << 8};
    bins PSEL_9 = {16'b1 << 9};
    bins PSEL_10 = {16'b1 << 10};
    bins PSEL_11 = {16'b1 << 11};
    bins PSEL_12 = {16'b1 << 12};
    bins PSEL_13 = {16'b1 << 13};
    bins PSEL_14 = {16'b1 << 14};
    bins PSEL_15 = {16'b1 << 15};
  }
	APB_CVR: cross RW, ERR, PSEL;

endgroup: apb_protocol_cg

// --------------------------------------------------------
// Methods
// --------------------------------------------------------
//
extern function new(string name = "apb_monitor_cov", uvm_component parent = null);
extern task run_phase(uvm_phase phase);
extern task monitor_apb();

endclass: apb_monitor_cov

// --------------------------------------------------------
// Extern methods
// --------------------------------------------------------
function apb_monitor_cov::new(string name = "apb_monitor_cov", uvm_component parent = null);
  super.new(name, parent);
  // Initialize covergroup array
  apb_protocol_cg = new();	
endfunction: new

task apb_monitor_cov::run_phase(uvm_phase phase);
  monitor_apb();
endtask: run_phase

// Monitor transactions on apb bus and sample when seeing a 
// transaction finished.
task apb_monitor_cov::monitor_apb();
  forever begin
    // Wait when transaction is successful
    wait(apb_intf.PREADY && apb_intf.PENABLE);
    // Sample covergroup
    apb_protocol_cg.sample();
    // Wait till previous transaction end
    wait(!apb_intf.PREADY);
  end
endtask: monitor_apb

`endif // APB_MONITOR_COV_SV
