// *************************************************************************************
// Copyright 2014 Mentor Graphics Corporation
// All Rights Reserved
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
//
// *************************************************************************************

`ifndef __SLI_RANDOM_SLEEP_SEQ
`define __SLI_RANDOM_SLEEP_SEQ

`include "uvm_macros.svh"
class random_sleep_seq extends uvm_sequence #(sli_clk_rst_item);
   `uvm_object_utils(random_sleep_seq)
   
   int min_sleep_time = 1;
   int max_sleep_time = 20;
   
   sli_clk_rst_item item;
   
   function new(string name="random_sleep_seq");
      super.new(name);
   endfunction : new
   
   task body;
      item = sli_clk_rst_item::type_id::create("item");
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
