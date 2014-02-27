//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : tap_1500_set_ir_seq
// File            : tap_1500_set_ir_seq.svh
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

`ifndef __ER_TAP_1500_SET_IR_SEQ
`define __ER_TAP_1500_SET_IR_SEQ

`include "uvm_macros.svh"

class er_tap_1500_set_ir_seq #(int IR_SIZE, type instruction_enum_t) extends er_tap_1500_base_sequence;

  `uvm_object_param_utils(er_tap_1500_set_ir_seq #(IR_SIZE,instruction_enum_t))    
//  int m_instruction;
  rand bit[IR_SIZE-1:0] m_instruction,m_old_instruction;
  er_tap_1500_item m_tr;
  
  function string get_type_name();
    return $psprintf("er_tap_1500_set_ir_seq #(%0d)",IR_SIZE);
  endfunction
  
  // constructor
  function new(string name = "uvm_sequence");

    super.new(name);
    // Insert Constructor Code Here

  endfunction : new


 

  task body();
    super.body();
    m_tr=er_tap_1500_item::type_id::create("m_tr");    
    `uvm_info(get_type_name(),$psprintf("Loading instruction: %0s",instruction_enum_t'(m_instruction)),UVM_MEDIUM);
    start_item(m_tr);
    assert(m_tr.randomize() with {m_tr.m_command == LOAD_REGISTER;
                                   m_tr.m_select_register == IR;
                                   m_tr.m_length == IR_SIZE;
                                   });
      foreach(m_instruction[i]) m_tr.m_data_in[i]=m_instruction[i];
     finish_item(m_tr);
//     m_tr.print();
     foreach (m_old_instruction[i]) m_old_instruction[i] = m_tr.m_data_out[i];
     `uvm_info(get_type_name(),$psprintf("Previous instruction: %0s",instruction_enum_t'(m_old_instruction)),UVM_MEDIUM);
     
  //  `uvm_info(get_type_name(),$psprintf("Updating IR",m_instruction),UVM_MEDIUM);
    start_item(m_tr);
    assert(m_tr.randomize() with {m_tr.m_command == UPDATE;
                                  m_tr.m_select_register == IR;
                                  m_tr.m_length == 0;
                                   });
     finish_item(m_tr);                            
    `uvm_info(get_type_name(),$psprintf("IR updated!(%s)",instruction_enum_t'(m_instruction)),UVM_MEDIUM);
  endtask




endclass : er_tap_1500_set_ir_seq

`endif