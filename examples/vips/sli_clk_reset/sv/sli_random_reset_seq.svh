// *************************************************************************************
// Copyright 2014 Mentor Graphics Corporation
// All Rights Reserved
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
//
// *************************************************************************************

`ifndef __SLI_RANDOM_RESET_SEQ
`define __SLI_RANDOM_RESET_SEQ

`include "uvm_macros.svh"
class random_reset_seq extends uvm_sequence #(sli_clk_rst_item);
   `uvm_object_utils(random_reset_seq)

   int max_delay_before_reset = 1000;
   int min_delay_before_reset = 1;
   int min_resume_time = 1;
   int max_resume_time = 20;
   int count = 10;

   sli_clk_rst_item item;
   

   
   function new(string name="sli_random_reset_seq");
      super.new(name);
   endfunction : new

   
   task body;
      item = sli_clk_rst_item::type_id::create("item");
      `uvm_info(get_type_name(),$psprintf("Will apply reset after %0d-%0d cycles from now",min_delay_before_reset,max_delay_before_reset),UVM_LOW);
      `uvm_info(get_type_name(),$psprintf("Reset will resume after %0d-%0d cycles once hit",min_resume_time,max_resume_time),UVM_LOW);
      `uvm_info(get_type_name(),$psprintf("Reset will be applied for %0d times",count),UVM_LOW);

      repeat(count) begin
	 start_item(item);
	 assert (item.randomize() with {item.m_cmd == ACTIVATE_RESET;
					item.m_delay >=min_delay_before_reset;
					item.m_delay <=max_delay_before_reset;
					});
      	 finish_item(item);


	 start_item(item);
	 assert (item.randomize() with {item.m_cmd == DEACTIVATE_RESET;
					item.m_delay >=min_resume_time;
					item.m_delay <=max_resume_time;
					});
      	 finish_item(item);
      end // repeat (count)
      
      `uvm_info(get_type_name(),"Sequence done!",UVM_MEDIUM);
   endtask //
   


   
endclass // random_reset_seq
`endif
