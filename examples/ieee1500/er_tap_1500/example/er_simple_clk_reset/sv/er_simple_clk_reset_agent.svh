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
// Unit            : er_simple_clk_reset_agent_agent
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
// er_simple_clk_reset_agent
//----------------------------------------------------------------------
class er_simple_clk_reset_agent extends uvm_agent;

  // configuration object
  er_simple_clk_reset_config m_cfg;

  // factory registration macro
  `uvm_component_utils(er_simple_clk_reset_agent)   


  // internal components
  er_simple_clk_reset_driver  m_driver;
  uvm_sequencer #(er_clk_rst_item, er_clk_rst_item)  m_sequencer;
  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name = "er_simple_clk_reset_agent", 
               uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  //--------------------------------------------------------------------
  // build_phase
  //--------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    
    if(!uvm_config_db #(er_simple_clk_reset_config)::get(this, "", "er_simple_clk_reset_config", m_cfg)) begin
      `uvm_error("build_phase", "er_simple_clk_reset_config not found")
    end    
     
     // Driver and Sequencer only built if agent is active
    if (m_cfg.is_active == UVM_ACTIVE) begin
      m_driver     = er_simple_clk_reset_driver::type_id::create("m_driver",this);
      m_sequencer  = uvm_sequencer #(er_clk_rst_item, er_clk_rst_item)::type_id::create("m_sequencer",this);
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

endclass: er_simple_clk_reset_agent

