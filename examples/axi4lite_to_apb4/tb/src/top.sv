// ************************************************************************
//               Copyright 2006-2015 Mentor Graphics Corporation
//                            All Rights Reserved.
//  
//               THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//             INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS 
//            CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                   TERMS.
//  
// ************************************************************************
//  
// DESCRIPTION   : AXI4Lite to APB4 Bridge - UVM testbench AXI4Lite to APB4 Bridge
// AUTHOR        : Mikael Andersson
// Last Modified : 1/18/15
// 
// ************************************************************************

module top;
   import uvm_pkg::*;
   import axi4lite_to_apb4_tb_pkg::*;

   // Clocks
   sli_clk_reset_if clk_apb4_m_if();
   sli_clk_reset_if clk_apb4_s_if();
   sli_clk_reset_if clk_axi4_if();
   
   
  // Instantiating the axi4 interface
  mgc_axi4 #(.AXI4_ADDRESS_WIDTH(AW), 
	     .AXI4_RDATA_WIDTH(DW), 
	     .AXI4_WDATA_WIDTH(DW), 
	     // Not used in lite
	     .AXI4_ID_WIDTH(AXI4_ID_WIDTH), 
	     .AXI4_USER_WIDTH(AXI4_USER_WIDTH), 
	     .AXI4_REGION_MAP_SIZE(AXI4_REGION_MAP_SIZE)) axi4_if(clk_axi4_if.clk,clk_axi4_if.nreset);
   

    // The instantiation of the interface                         

   // CSR Master
   mgc_apb3 #( SLAVE_COUNT,
               APB4_AW,
               APB4_DW, 
               APB4_DW ) apb4_master_if(clk_apb4_m_if.clk,clk_apb4_m_if.nreset);

   // Slave
   mgc_apb3 #( SLAVE_COUNT,
               APB4_AW,
               APB4_DW, 
               APB4_DW ) apb4_slave_if(clk_apb4_s_if.clk,clk_apb4_s_if.nreset);
   

   
   // dut
   axi4lite_to_apb4 #(.AW(AW), .DW(DW),.USE_1CLK(USE_1CLK),.BLOCK_START_ADDRESS(0)) dut (
					     // APB4 Master Interface Signals
					     .PSELx_o(apb4_slave_if.PSEL),
					     .PCLK_i(clk_apb4_s_if.clk),
					     .PRESETn_i(clk_apb4_s_if.nreset),
					     .PADDR_o(apb4_slave_if.PADDR),
					     .PENABLE_o(apb4_slave_if.PENABLE),
					     .PWRITE_o(apb4_slave_if.PWRITE),
					     .PPROT_o(apb4_slave_if.PPROT),
					     .PWDATA_o(apb4_slave_if.PWDATA),
					     .PSTRB_o(apb4_slave_if.PSTRB),
					     
					     .PREADY_i(apb4_slave_if.PREADY),
					     .PRDATA_i(apb4_slave_if.PRDATA),
					     .PSLVERR_i(apb4_slave_if.PSLVERR),
					     
					     // APB Interface Signals
					     .PSELx_i_csr(apb4_master_if.PSEL),
					     .PCLK_i_csr(clk_apb4_m_if.clk),
					     .PRESETn_i_csr(clk_apb4_m_if.nreset),
					     .PENABLE_i_csr(apb4_master_if.PENABLE),
					     .PADDR_i_csr(apb4_master_if.PADDR),
					     .PWRITE_i_csr(apb4_master_if.PWRITE),
					     .PWDATA_i_csr(apb4_master_if.PWDATA),
					     .PRDATA_o_csr(apb4_master_if.PRDATA),
					     
					     // AXI4Lite Slave Signals
					     .ACLK_i(clk_axi4_if.clk),
					     .ARESETn_i(clk_axi4_if.nreset),
					     // WA Channel
					     .AWADDR_i(axi4_if.AWADDR),
					     .AWPROT_i(axi4_if.AWPROT),
					     .AWVALID_i(axi4_if.AWVALID),
					     .AWREADY_o(axi4_if.AWREADY),
					     // WD Channel
					     .WDATA_i(axi4_if.WDATA),
					     .WSTRB_i(axi4_if.WSTRB),
					     .WVALID_i(axi4_if.WVALID),
					     .WREADY_o(axi4_if.WREADY),
					     // WR Channel
					     .BRESP_o(axi4_if.BRESP),
					     .BVALID_o(axi4_if.BVALID),
					     .BREADY_i(axi4_if.BREADY),
					     // RA Channel
					     .ARADDR_i(axi4_if.ARADDR),
					     .ARPROT_i(axi4_if.ARPROT),
					     .ARVALID_i(axi4_if.ARVALID),
					     .ARREADY_o(axi4_if.ARREADY),
					     // RD Channel
					     .RDATA_o(axi4_if.RDATA),
					     .RRESP_o(axi4_if.RRESP),
					     .RVALID_o(axi4_if.RVALID),
					     .RREADY_i(axi4_if.RREADY)
					     );


//   assign apb4_master_if.PREADY = dut.u_csr_interface_apb.i_registers.rack;
   
   assign apb4_master_if.PSLVERR = 1'b0;
   assign axi4_if.BREADY='1;
   assign axi4_if.ARVALID='0;
   assign axi4_if.AWVALID='0;
   assign axi4_if.WVALID='0;
   
   
 initial 
  begin
    uvm_config_db #( axi4_if_t )::set( null , "uvm_test_top", "AXI4_M_IF", axi4_if);
    uvm_config_db #( apb3_if_t )::set( null , "uvm_test_top", "APB4_M_IF", apb4_master_if);
    uvm_config_db #( apb3_if_t )::set( null , "uvm_test_top", "APB4_S_IF", apb4_slave_if);
    uvm_config_db #( virtual sli_clk_reset_if )::set( null , "uvm_test_top", "SLI_CLK_RESET_AXI4_IF", clk_axi4_if);
    uvm_config_db #( virtual sli_clk_reset_if )::set( null , "uvm_test_top", "SLI_CLK_RESET_APB4_M_IF", clk_apb4_m_if);
    uvm_config_db #( virtual sli_clk_reset_if )::set( null , "uvm_test_top", "SLI_CLK_RESET_APB4_S_IF", clk_apb4_s_if);
    run_test("axi4_to_apb4_basetest");
  end

endmodule
