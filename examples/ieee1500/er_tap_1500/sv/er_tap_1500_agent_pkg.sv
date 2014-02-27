//----------------------------------------------------------------------
//                   Mentor Graphics Corporation
//----------------------------------------------------------------------
// Project         : ieee1500
// Unit            : er_tap_1500_agent_agent_pkg
// File            : er_tap_1500_agent_agent_pkg.svh
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
// er_tap_1500_agent_pkg
//----------------------------------------------------------------------
package er_tap_1500_agent_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

// Typedefs used by the seq item
  typedef enum {UPDATE,LOAD_REGISTER,CAPTURE} command_t;
  typedef enum {DR,IR} sel_reg_t;
  typedef enum {OK,TRANSFER_ABORTED_DUE_TO_RESET} status_t;
  typedef enum {UNCONFIGURED,MASTER,SLAVE} agent_mode_t;

  // Include the sequence_items (transactions)
  `include "er_tap_1500_item.svh"  

  // Include the agent config object
  `include "er_tap_1500_agent_config.svh"

  // Include the components  
  `include "er_tap_1500_base_driver.svh"
  `include "er_tap_1500_slave_driver.svh" 
  `include "er_tap_1500_master_driver.svh" 
  
  `include "er_tap_1500_monitor.svh"
  `include "er_tap_1500_agent.svh"
  `include "er_tap_1500_base_sequence.svh"
  `include "er_tap_1500_set_ir_seq.svh"

  
endpackage: er_tap_1500_agent_pkg

