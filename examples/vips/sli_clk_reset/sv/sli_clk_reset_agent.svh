// *************************************************************************************
// Copyright 2014 Mentor Graphics Corporation
// All Rights Reserved
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
//
// bugs, enhancement requests to: avidan_efody@mentor.com
// *************************************************************************************

class sli_clk_reset_agent extends uvm_agent;

  // configuration object
  sli_clk_reset_config m_cfg;

  // factory registration macro
  `uvm_component_utils(sli_clk_reset_agent)   


  // internal components
  sli_clk_reset_driver  m_driver;
  uvm_sequencer #(sli_clk_rst_item, sli_clk_rst_item)  m_sequencer;
  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name = "sli_clk_reset_agent", 
               uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  //--------------------------------------------------------------------
  // build_phase
  //--------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    
    if(!uvm_config_db #(sli_clk_reset_config)::get(this, "", "sli_clk_reset_config", m_cfg)) begin
      `uvm_error("build_phase", "sli_clk_reset_config not found")
    end    
     
     // Driver and Sequencer only built if agent is active
    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_driver     = sli_clk_reset_driver::type_id::create("m_driver",this);
      m_sequencer  = uvm_sequencer #(sli_clk_rst_item, sli_clk_rst_item)::type_id::create("m_sequencer",this);
    end 
  endfunction: build_phase

  //--------------------------------------------------------------------
  // connect_phase
  //--------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    // Driver and Sequencer only connected if agent is active    
    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
      m_cfg.m_sequencer = m_sequencer;
    end     
    
  endfunction: connect_phase

endclass: sli_clk_reset_agent

