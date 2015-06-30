//
//  Module: APB3 monitor testbench
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

module apb_monitor_tb;

import uvm_pkg::*;
`include "uvm_macros.svh"

import apb_monitor_pkg::*;

// -------------------------
// Signal declaration
// -------------------------
logic PCLK;
logic PRESETn;

// --------------------------
// Connecting the interface
// --------------------------
apb_if apb_intf(.PCLK, .PRESETn);

// Assertion checker interface 
apb_monitor_assert_if apb_checker_assert_intf(.PCLK,
                              .PRESETn,
                              .PADDR(apb_intf.PADDR),
                              .PWDATA(apb_intf.PWDATA),
                              .PRDATA(apb_intf.PRDATA),
                              .PSEL(apb_intf.PSEL),
                              .PWRITE(apb_intf.PWRITE),
                              .PENABLE(apb_intf.PENABLE),
                              .PREADY(apb_intf.PREADY),
                              .PSLVERR(apb_intf.PSLVERR));

// ----------------------------------
// Clock generation and system reset
// ----------------------------------
initial begin
  PCLK <= 0;
  PRESETn <= 0;
  repeat(10) begin
    #10 PCLK <= ~PCLK;
  end
  PRESETn <= 1;

  // Clock
  forever begin
    #10 PCLK <= ~PCLK;
  end
end

// -----------------------------------
// Start the test
// -----------------------------------
// Generate some simple stimulus based on the tasks
initial begin
  // Pass the virtual interface handle
  uvm_config_db # (virtual apb_if)::set(null, "uvm_test_top*", "apb_intf", apb_intf);

  run_test();
end

endmodule: apb_monitor_tb
