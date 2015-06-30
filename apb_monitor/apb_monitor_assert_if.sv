//
//  Module: APB3 monitor interface 
//  Author: Lianghao Yuan
//  Email: yuanlianghao@gmail.com
//  Date: 06/29/2015
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
`ifndef APB_MONITOR_ASSERT_IF_SV
`define APB_MONITOR_ASSERT_IF_SV

interface apb_monitor_assert_if(input PCLK,
                                input PRESETn,
                                input [31:0] PADDR,
                                input [31:0] PWDATA,
                                input [31:0] PRDATA,
                                input [15:0] PSEL,
                                input PWRITE,
                                input PENABLE,
                                input PREADY,
                                input PSLVERR);
// -----------------------------------
// Assertions
// -----------------------------------

// Check for unknown signal values;
//
// Reusable property to check that a signal is in safe state
property SIGNAL_VALID(signal);
	@(posedge apb_intf.PCLK)
	!$isunknown(signal);
endproperty: SIGNAL_VALID

RESET_VALID: assert property(SIGNAL_VALID(apb_intf.PRESETn));
PSEL_VALID: assert property(SIGNAL_VALID(apb_intf.PSEL));

// Reusable property to check that if any PSEL is active, then
// the signal is valid.
property CONTROL_SIGNAL_VALID(signal);
	@(posedge apb_intf.PCLK)
	$onehot(apb_intf.PSEL) |-> !$isunknown(signal);
endproperty: CONTROL_SIGNAL_VALID

PADDR_VALID: assert property(CONTROL_SIGNAL_VALID(apb_intf.PADDR));
PWRITE_VALID: assert property(CONTROL_SIGNAL_VALID(apb_intf.PADDR));
PENABLE_VALID: assert property(CONTROL_SIGNAL_VALID(apb_intf.PENABLE));

// Check that write data is valid if a write
property PWDATA_SIGNAL_VALID;
	@(posedge apb_intf.PCLK)
	($onehot(apb_intf.PSEL) && apb_intf.PWRITE) |-> !$isunknown(apb_intf.PWDATA);
endproperty: PWDATA_SIGNAL_VALID

PWDATA_VALID: assert property(PWDATA_SIGNAL_VALID);

// Check that if PENABLE is active, then the signal is valid
property PENABLE_SIGNAL_VALID(signal);
	@(posedge apb_intf.PCLK)
	$rose(apb_intf.PENABLE) |-> !$isunknown(signal)[*1:$] ##1 $fell(apb_intf.PENABLE);
endproperty: PENABLE_SIGNAL_VALID

PREADY_VALID: assert property(PENABLE_SIGNAL_VALID(apb_intf.PREADY));

// Check if PREADY is active, then PSLVERR is valid
property PSLVERR_SIGNAL_VALID;
	@(posedge apb_intf.PCLK)
	apb_intf.PREADY |-> !$isunknown(apb_intf.PSLVERR);
endproperty: PSLVERR_SIGNAL_VALID

PSLVERR_VALID: assert property(PSLVERR_SIGNAL_VALID);

// Check that read data is valid if a read
property PRDATA_SIGNAL_VALID;
	@(posedge apb_intf.PCLK)
	($rose(apb_intf.PENABLE && !apb_intf.PWRITE && apb_intf.PREADY)) |-> !$isunknown(apb_intf.PRDATA)[*1:$] ##1 $fell(apb_intf.PENABLE);
endproperty: PRDATA_SIGNAL_VALID

PRDATA_VALID: assert property(PRDATA_SIGNAL_VALID);


// Timing relationship checks
//
// When PREADY is active, signal is de-asserted in next cycle.
property PREADY_SIGNAL_DEASSERTED(signal);
	@(posedge apb_intf.PCLK)
	$rose(apb_intf.PREADY) |=> $fell(signal); 
endproperty: PREADY_SIGNAL_DEASSERTED

PREADY_DEASSERT: assert property(PREADY_SIGNAL_DEASSERTED(apb_intf.PREADY));
COV_PREADY_DEASSERT: cover property(PREADY_SIGNAL_DEASSERTED(apb_intf.PREADY));
PENABLE_DEASSERT: assert property(PREADY_SIGNAL_DEASSERTED(apb_intf.PENABLE));
COV_PENABLE_DEASSERT: cover property(PREADY_SIGNAL_DEASSERTED(apb_intf.PENABLE));


// When PSEL is active, PENABLE goes high in next cycle.
property PSEL_TO_PENABLE_ACTIVE;
	@(posedge apb_intf.PCLK)
	(!$stable(apb_intf.PSEL) && $onehot(apb_intf.PSEL)) |=> $rose(apb_intf.PENABLE);
endproperty: PSEL_TO_PENABLE_ACTIVE

PSEL_TO_PENABLE: assert property(PSEL_TO_PENABLE_ACTIVE);
COV_PSEL_TO_PENABLE: cover property(PSEL_TO_PENABLE_ACTIVE);

// From PSEL being active, the signal must be stable until end of transaction
property PSEL_ASSERT_SIGNAL_STABLE(signal);
	@(posedge apb_intf.PCLK)
  (!$stable(apb_intf.PSEL) && $onehot(apb_intf.PSEL)) |=> $stable(signal)[*1:$] ##1 $fell(apb_intf.PENABLE);
endproperty: PSEL_ASSERT_SIGNAL_STABLE

PSEL_STABLE: assert property(PSEL_ASSERT_SIGNAL_STABLE(apb_intf.PSEL));
COV_PSEL_STABLE: cover property(PSEL_ASSERT_SIGNAL_STABLE(apb_intf.PSEL));
PWRITE_STABLE: assert property(PSEL_ASSERT_SIGNAL_STABLE(apb_intf.PWRITE));
COV_PWRITE_STABLE: cover property(PSEL_ASSERT_SIGNAL_STABLE(apb_intf.PWRITE));
PADDR_STABLE: assert property(PSEL_ASSERT_SIGNAL_STABLE(apb_intf.PADDR));
COV_PADDR_STABLE: cover property(PSEL_ASSERT_SIGNAL_STABLE(apb_intf.PADDR));
PWDATA_STABLE: assert property(PSEL_ASSERT_SIGNAL_STABLE(apb_intf.PWDATA));
COV_PWDATA_STABLE: cover property(PSEL_ASSERT_SIGNAL_STABLE(apb_intf.PWDATA));

// Other checks
//
// PSEL is onehot, at most one line can be active
property PSEL_ONEHOT;
	@(posedge apb_intf.PCLK)
	$onehot0(apb_intf.PSEL);
endproperty: PSEL_ONEHOT

PSEL_ONLY_ONE: assert property(PSEL_ONEHOT);

endinterface: apb_monitor_assert_if

`endif // APB_MONITOR_ASSERT_IF_SV
