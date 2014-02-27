//----------------------------------------------------------------------
//                   Mentor Graphics Inc
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : er_tap_1500_slave_driver
// File            : er_tap_1500_slave_driver.svh
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

`ifndef __TAP_1500_SLAVE_DRIVER
`define __TAP_1500_SLAVE_DRIVER

`include "uvm_macros.svh"

class er_tap_1500_slave_driver extends er_tap_1500_base_driver;

  `uvm_component_utils(er_tap_1500_slave_driver)    
  
  // constructor
  function new(string name = "er_tap_1500_base_driver", uvm_component parent = null);

    super.new(name, parent);
    // Insert Constructor Code Here

  endfunction : new

  // build_phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Insert Build Code Here
    `uvm_error(get_type_name(),"Not yet implemented");
  endfunction : build_phase



  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

  endfunction : connect_phase



endclass : er_tap_1500_slave_driver

`endif