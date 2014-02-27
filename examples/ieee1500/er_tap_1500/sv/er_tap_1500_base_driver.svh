//----------------------------------------------------------------------
//                   Mentor Graphics Corporation
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : er_tap_1500_base_driver
// File            : er_tap_1500_base_driver.svh
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
// er_tap_1500_base_driver
//----------------------------------------------------------------------
class er_tap_1500_base_driver extends uvm_driver #(er_tap_1500_item, er_tap_1500_item);

  // factory registration macro
  `uvm_component_utils(er_tap_1500_base_driver)  

  // internal components 
  er_tap_1500_item    m_req;
  er_tap_1500_item    m_rsp;
  bit response_sent;
  // interface  
  virtual er_tap_1500_if  vif;

  // local variables
  int tests = 0;
  er_tap_1500_agent_config m_cfg;

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------    
  function new (string name = "er_tap_1500_base_driver",
                uvm_component parent = null);
    super.new(name,parent);
  endfunction: new


  //--------------------------------------------------------------------
  // report_phase
  //--------------------------------------------------------------------  
  virtual function void report_phase(uvm_phase phase);
    string s;  
    $sformat(s, "%0d sequence items", tests);
    `uvm_info({get_type_name(),":report"}, s, UVM_MEDIUM )
  endfunction: report_phase

 
  
endclass: er_tap_1500_base_driver

