// *************************************************************************************
// Copyright 2014 Mentor Graphics Corporation
// All Rights Reserved
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
//
// *************************************************************************************

package sli_clk_reset_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  typedef enum {DEACTIVATE_RESET,ACTIVATE_RESET} cmd_t;



  // Include the sequence_items (transactions)
  `include "sli_clk_rst_item.svh"  

  // Include the agent config object
  `include "sli_clk_reset_config.svh"

  // Include the components  
  `include "sli_clk_reset_driver.svh"
  `include "sli_clk_reset_agent.svh"
  `include "sli_random_reset_seq.svh"
  `include "sli_random_sleep_seq.svh"
  
endpackage: sli_clk_reset_pkg

