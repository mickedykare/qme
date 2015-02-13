package axi4lite_to_apb4_tb_pkg;
   import uvm_pkg::*;
   import mvc_pkg::*;
   import mgc_apb3_v1_0_pkg::*;
   import mgc_axi4_v1_0_pkg::*;
   import axi4lite_to_apb4_regs_pkg::*;
   import sli_clk_reset_pkg::*;
   
   
// Not used in LITE
   parameter AXI4_ID_WIDTH=2;
   parameter AXI4_USER_WIDTH=2;
   parameter AXI4_REGION_MAP_SIZE=2;
   parameter SLAVE_COUNT=1;
   parameter APB4_AW=32;   
   parameter APB4_DW=32;
   parameter AW=32;
   parameter DW=32;
		     
   // Testing different widths   
`ifdef SETUP_MC
   parameter USE_1CLK = 1'b0;
`else
   parameter USE_1CLK = 1'b1;
`endif // !`ifdef SETUP64


   // axi4 lite interface
   typedef virtual mgc_axi4 #(.AXI4_ADDRESS_WIDTH(AW), 
			      .AXI4_RDATA_WIDTH(DW), 
			      .AXI4_WDATA_WIDTH(DW), 
			      // Not used in lite
			      .AXI4_ID_WIDTH(AXI4_ID_WIDTH), 
			      .AXI4_USER_WIDTH(AXI4_USER_WIDTH), 
			      .AXI4_REGION_MAP_SIZE(AXI4_REGION_MAP_SIZE) ) axi4_if_t;
   
   // Typedef for the virtual interface
   typedef virtual mgc_apb3 #(SLAVE_COUNT,
                              APB4_AW,
                              APB4_DW,
                              APB4_DW) apb3_if_t ;   



   typedef    apb3_vip_config #( SLAVE_COUNT  , 
				 APB4_AW,
				 APB4_DW  ,
				 APB4_DW) apb4_config_t;
   
   

   typedef axi4_vip_config #(AW,
                             DW,
                             DW,
                             AXI4_ID_WIDTH,
                             AXI4_USER_WIDTH,
                             AXI4_REGION_MAP_SIZE 
                             ) axi4_config_t;


 typedef apb3_transaction_memory_sequence #( SLAVE_COUNT,
                                              APB4_AW,
                                              APB4_DW,
                                              APB4_DW) apb4_slave_seq_t;     



   typedef apb3_host_apb3_transaction #(SLAVE_COUNT,
					APB4_AW ,
					APB4_DW ,
					APB4_DW) apb3_host_apb3_transaction_t;
   

   
  typedef reg2apb_adapter #(apb3_host_apb3_transaction_t, 
                            SLAVE_COUNT, 
                            APB4_AW, 
                            APB4_DW, 
                            APB4_DW) reg2apb_adapter_t; 

  typedef apb_reg_predictor #(apb3_host_apb3_transaction_t, 
                              SLAVE_COUNT, 
                              APB4_AW, 
                              APB4_DW, 
                              APB4_DW) apb3_reg_predictor_t;



   

`include "uvm_macros.svh"
`include "qvip_err_assertion_report.svh";
`include "axi4lite_to_apb4_env.svh";
`include "axi4lite_to_apb4_basetest.svh";
`include "axi4lite_apb4_reg_test.svh";
   


   
   
endpackage // axi4lite_to_apb4_tb_pkg
   