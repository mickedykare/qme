//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : my_project
// Unit            : er_tap_1500_smoke_test
// File            : er_tap_1500_smoke_test.svh
//----------------------------------------------------------------------
// Created by      : mikaela.mikaela
// Creation Date   : 2014/01/30
//----------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------

`ifndef __ER_TAP_1500_SMOKE_TEST
`define __ER_TAP_1500_SMOKE_TEST

class er_tap_1500_smoke_test extends tap_1500_base_test;
  `uvm_component_utils(er_tap_1500_smoke_test)
  
  er_tap_1500_set_ir_seq #(IR_SIZE_P,ws_instruction_t)  m_seq;
  // constructor
  function new(string name, uvm_component parent);

    super.new(name, parent);
    // Insert Constructor Code Here

  endfunction : new

task run_phase(uvm_phase phase);
  m_seq=er_tap_1500_set_ir_seq#(IR_SIZE_P,ws_instruction_t)::type_id::create("m_seq");
  phase.raise_objection(this);
  #100ns;
  m_seq.m_instruction=WS_EXTEST;
  m_seq.start( m_tap_1500_agent_config.m_sequencer);
  m_seq.m_instruction=WS_BYPASS;
  m_seq.start( m_tap_1500_agent_config.m_sequencer);
  #100ns;
  phase.drop_objection(this);
endtask

  

endclass : er_tap_1500_smoke_test

`endif