//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : tap_1500_base_sequence
// File            : tap_1500_base_sequence.svh
//----------------------------------------------------------------------
// Created by      : mikaela.mikaela
// Creation Date   : 2014/01/29
//----------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------

`ifndef __ER_TAP_1500_BASE_SEQUENCE
`define __ER_TAP_1500_BASE_SEQUENCE

`include "uvm_macros.svh"

class er_tap_1500_base_sequence extends uvm_sequence #(er_tap_1500_item);

   `uvm_object_utils(er_tap_1500_base_sequence)   
   er_tap_1500_agent_config m_cfg;
   
   // constructor
   function new(string name = "uvm_sequence");
      super.new(name);
      // Insert Constructor Code Here
   endfunction : new

   task body;
      //This picks up some nice to know things,like the IR length
//      if(!uvm_config_db #(er_tap_1500_agent_config)::get(uvm_test_top, "", "er_tap_1500_agent_config", m_cfg)) begin
//	 `uvm_error(get_type_name(), "er_tap_1500_agent_config not found")
//      end    
   endtask
   
   

endclass : er_tap_1500_base_sequence

`endif