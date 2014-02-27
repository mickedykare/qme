package tap_1500_tb_pkg;
   import uvm_pkg::*;
   import er_simple_clk_reset_pkg::*;
   import er_tap_1500_agent_pkg::*;
   
   parameter IR_SIZE_P=4;
   typedef enum {WS_BYPASS=32'hf,
                 WS_EXTEST=32'h0,
                 WS_PRELOAD=32'h1} ws_instruction_t;
    
    
`include "uvm_macros.svh"
 
`include "tap_1500_env.svh"
`include "tap_1500_base_test.svh"
`include "er_tap_1500_smoke_test.svh" 
		     
		
	 
   




endpackage // tap_1500_tb_pkg
   