//
//  Module: APB3 monitor env (just a dummy env, simply connecting apb_monitor_cov
//  to apb_if)
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

`ifndef APB_MONITOR_ENV_SVH
`define APB_MONITOR_ENV_SVH

class apb_monitor_env extends uvm_env;
`uvm_component_utils(apb_monitor_env)
// -----------------------------
// Member components
//------------------------------
apb_monitor_cov m_apb_monitor_cov;

// -----------------------------
// Methods
// -----------------------------
function new(string name = "apb_monitor_env", uvm_component parent = null);
  super.new(name, parent);
endfunction: new

function void build_phase(uvm_phase phase);
  m_apb_monitor_cov = apb_monitor_cov::type_id::create("m_apb_monitor_cov", this);
endfunction: build_phase

function void connect_phase(uvm_phase phase);
  if(!uvm_config_db # (virtual apb_if)::get(this, "", "apb_intf", m_apb_monitor_cov.apb_intf)) begin
    `uvm_error("connect_phase", "Unable to find apb_intf in uvm_config_db")
  end
endfunction: connect_phase
endclass: apb_monitor_env

`endif // APB_MONITOR_ENV_SVH
