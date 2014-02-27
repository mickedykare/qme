//----------------------------------------------------------------------------
//                                                                          --
//     COPYRIGHT (C)                                ERICSSON  AB,  2012     --
//                                                                          --
//     Ericsson AB, Sweden.                                                 --
//                                                                          --
//     The document(s) may be used  and/or copied only with the written     --
//     permission from Ericsson AB  or in accordance with the terms and     --
//     conditions  stipulated in the agreement/contract under which the     --
//     document(s) have been supplied.                                      --
//                                                                          --
//----------------------------------------------------------------------------
// Unit            : er_simple_clk_reset_config
//----------------------------------------------------------------------------
// Created by      : qmikand
// Creation Date   : 2012/06/19
//----------------------------------------------------------------------------
// Title: 
//
// Summary:
//
// Description:
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------
// er_simple_clk_reset_config
//----------------------------------------------------------------------
class er_simple_clk_reset_config extends uvm_object;
  
  // factory registration macro
  `uvm_object_utils(er_simple_clk_reset_config)
    
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
  virtual er_simple_clk_reset_if  vif;

  // sequencer handle
  uvm_sequencer #(er_clk_rst_item, er_clk_rst_item)  m_sequencer;

  // set this to 0 and use er_simple_clk_reset_enable_driver to turn clock off
  bit m_clk_enable = 1;
  
  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name = "er_simple_clk_reset_config");
    super.new(name);
  endfunction: new


endclass: er_simple_clk_reset_config

