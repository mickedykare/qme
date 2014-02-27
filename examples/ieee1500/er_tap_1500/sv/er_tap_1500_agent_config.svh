//----------------------------------------------------------------------
//                   Mentor Graphics Corporation
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : er_tap_1500_agent_config
// File            : er_tap_1500_agent_config.svh
//----------------------------------------------------------------------
// Created by      : mikaela
// Creation Date   : 2014/01/29
//----------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// er_tap_1500_agent_config
//----------------------------------------------------------------------
class er_tap_1500_agent_config extends uvm_object;
  
  // factory registration macro
  `uvm_object_utils(er_tap_1500_agent_config)

  // agent configuration
  uvm_active_passive_enum is_active = UVM_ACTIVE;   

  // virtual interface handle:
  virtual er_tap_1500_if  vif;
  
  // pointer to sequencer 
  uvm_sequencer #(er_tap_1500_item) m_sequencer;
  
  
  agent_mode_t m_agent_mode=UNCONFIGURED;
  


  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name = "er_tap_1500_agent_config");
    super.new(name);
  endfunction: new


endclass: er_tap_1500_agent_config

