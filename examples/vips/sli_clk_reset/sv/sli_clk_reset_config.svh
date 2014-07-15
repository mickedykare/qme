// *************************************************************************************
// Copyright 2014 Mentor Graphics Corporation
// All Rights Reserved
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
//
// *************************************************************************************

class sli_clk_reset_config extends uvm_object;
  
  // factory registration macro
  `uvm_object_utils(sli_clk_reset_config)
    
    time m_clk_period=10ns;
    
    // initial delay of reset
    rand int m_reset_delay;
    rand bit m_clk_initial_value;
    
    constraint C1 {
      m_reset_delay > 0;
      m_reset_delay < 100;
      }
    

  // agent configuration
  uvm_active_passive_enum is_active = UVM_ACTIVE;   

  // virtual interface handle:
  virtual sli_clk_reset_if  vif;

  // sequencer handle
  uvm_sequencer #(sli_clk_rst_item, sli_clk_rst_item)  m_sequencer;

  // set this to 0 and use sli_clk_reset_enable_driver to turn clock off
  bit m_clk_enable = 1;
  
  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name = "sli_clk_reset_config");
    super.new(name);
  endfunction: new


endclass: sli_clk_reset_config

