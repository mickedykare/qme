package fpu_agent_pkg;

  import uvm_pkg::*;
  import uvmc_pkg::*; 

   typedef enum     {LT_MODE,AT_MODE} tlm_timing_mode_t;
   typedef enum     {UNCONFIGURED,
                     RTL_SLAVE,
                     RTL_MASTER,
                     TLM_SLAVE,
                     TLM_MASTER} agent_mode_t;

   typedef enum      {UNCONFIGURED_SOCKET,
                      TARGET_SOCKET,
                      INITIATOR_SOCKET} socket_type_t;
   typedef enum      {TRANSFER_OK,TRANSFER_ABORTED_DUE_TO_RESET} tlm_status_t;

`include "uvm_macros.svh";

`include "fpu_agent_config.svh"; 
`include "fpu_sv_utils.svh";

`include "fpu_gp_ext.svh";
`include "fpu_item.svh";
`include "fpu_item_seq.svh";
`include "fpu_sequencer.svh";
`include "fpu_sequence_driver.svh";
`include "fpu_monitor.svh";
`include "fpu_coverage.svh";

`include "fpu_base_driver.svh";
`include "fpu_tlm_master_driver.svh";
`include "fpu_tlm_target.svh";
`include "fpu_ap2seq_export.svh";

`include "fpu_item2gp_adaptor.svh";

`include "fpu_agent.svh";

`include "fpu_sequence_library.svh";

endpackage // fpu_agent_pkg

