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
// Unit            : er_simple_clk_reset_agent_pkg
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
// er_simple_clk_reset_pkg
//----------------------------------------------------------------------
package er_simple_clk_reset_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  typedef enum {DEACTIVATE_RESET,ACTIVATE_RESET} cmd_t;



  // Include the sequence_items (transactions)
  `include "er_clk_rst_item.svh"  

  // Include the agent config object
  `include "er_simple_clk_reset_config.svh"

  // Include the components  
  `include "er_simple_clk_reset_driver.svh"
  `include "er_simple_clk_reset_agent.svh"
  `include "random_reset_seq.svh"
  `include "random_sleep_seq.svh"
  
endpackage: er_simple_clk_reset_pkg

