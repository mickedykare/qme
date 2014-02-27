//-----------------------------------------------------------------------------
// COPYRIGHT (c)  Ericsson AB, Sweden, 2013
// The copyright to the document(s) herein is the property of
// Ericsson AB, Sweden.
//
// The document(s) may be used and/or copied only with the written
// permission from Ericsson AB, Sweden, or in accordance with 
// the terms and conditions stipulated in the agreement/contract
// under which the document(s) have been supplied.
//
// All rights reserved.
//-----------------------------------------------------------------------------
//
// Author:  evyzadh
// Created: Sun Mar 17 12:38:26 CET 2013
// @(#) ClearCase ID: /vobs/asic/cab/ver/vip/vip_lib/er_simple_clk_reset/sv/random_sleep_seq.svh /main/2 13-05-08 09:33 evyzadh #
//
//-----------------------------------------------------------------------------
// Description:
//
// This file implements a sequence witch waits for a random number of clock cycles
// 
//
//-----------------------------------------------------------------------------
// SystemVerilog Version: IEEE Std 1800-2005
//
//-----------------------------------------------------------------------------

`ifndef __RANDOM_SLEEP_SEQ
`define __RANDOM_SLEEP_SEQ

`include "uvm_macros.svh"
class random_sleep_seq extends uvm_sequence #(er_clk_rst_item);
   `uvm_object_utils(random_sleep_seq)

   int min_sleep_time = 1;
   int max_sleep_time = 20;

   er_clk_rst_item item;
   
   function new(string name="random_sleep_seq");
      super.new(name);
   endfunction : new
   
   task body;
      item = er_clk_rst_item::type_id::create("item");
      `uvm_info(get_type_name(),$psprintf("Sleeping for %0d-%0d clock cycles",min_sleep_time,max_sleep_time),UVM_LOW);

	 start_item(item);
	 assert (item.randomize() with {item.m_cmd == DEACTIVATE_RESET;
					item.m_delay >=min_sleep_time;
					item.m_delay <=max_sleep_time;
					});
      	 finish_item(item);
      
      `uvm_info(get_type_name(),"Sequence done!",UVM_MEDIUM);
   endtask // body

   
endclass : random_sleep_seq

`endif
