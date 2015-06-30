//
//  Module: APB3 interface
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
`ifndef APB_IF_SV
`define APB_IF_SV

 interface apb_if (input PCLK,
                   input PRESETn);

  logic [31:0] PADDR;
  logic [31:0] PWDATA;
  logic [31:0] PRDATA;
  logic [15:0] PSEL;
  logic PWRITE;
  logic PENABLE;
  logic PREADY;
  logic PSLVERR;

endinterface: apb_if

`endif // APB_IF_SV

