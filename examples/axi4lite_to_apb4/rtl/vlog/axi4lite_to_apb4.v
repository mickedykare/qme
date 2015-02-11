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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - Top module
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/12/15
// 
// ************************************************************************

module axi4lite_to_apb4 #(
			  parameter AW  = 32,
			  parameter DW  = 32, 
			  parameter USE_1CLK=1'b0


)
(
// APB4 Master Interface Signals
  output                        PSELx_o,
  input                 	PCLK_i,
  input                 	PRESETn_i,
  output  [31:0]         	PADDR_o,
  output			PENABLE_o,
  output                 	PWRITE_o,
  output  [2:0]			PPROT_o,
  output  [DW-1:0] 	  	PWDATA_o,
  output  [(DW/8)-1:0]		PSTRB_o,
  input 	               	PREADY_i,
  input [DW-1:0]   		PRDATA_i,
  input				PSLVERR_i,


// APB2 Interface Signals (Mem Reg)
  input             		PSELx_i_csr,
  input             		PCLK_i_csr,
  input             		PRESETn_i_csr,
  input             		PENABLE_i_csr,
  input  [31:0] 		PADDR_i_csr,
  input           		PWRITE_i_csr,
  input  [31:0] 		PWDATA_i_csr,
  output [31:0] 		PRDATA_o_csr,


// AXI4Lite Slave Signals
  input 			ACLK_i,
  input				ARESETn_i,
// WA Channel
  input [AW-1:0]		AWADDR_i,
  input [2:0] 			AWPROT_i,
  input		        	AWVALID_i,
  output	        	AWREADY_o,
// WD Channel
  input [DW-1:0]		WDATA_i,
  input [(DW/8)-1:0]		WSTRB_i,
  input 			WVALID_i,
  output			WREADY_o,
// WR Channel
  output  [1:0]			BRESP_o,
  output			BVALID_o,
  input				BREADY_i,
// RA Channel
  input [AW-1:0]   		ARADDR_i,
  input [2:0]          		ARPROT_i,
  input       			ARVALID_i,
  output        	 	ARREADY_o,
// RD Channel
  output  [DW-1:0]   		RDATA_o,
  output  [1:0]          	RRESP_o,
  output                 	RVALID_o,
  input                		RREADY_i
);


// signal definitions
wire [AW+2:0]        waddr_prot_wdata;
wire [AW+2:0]        waddr_prot_rdata;
wire                 waddr_wen_push;
wire                 waddr_wen_pop;
wire                 waddr_fifo_full;
wire                 waddr_fifo_empty;
wire [(DW/8)+DW-1:0] data_strb_wdata;
wire [(DW/8)+DW-1:0] data_strb_rdata;
wire                 data_wen_push;
wire                 data_wen_pop;
wire                 data_fifo_full;
wire                 data_fifo_empty;
wire [AW+2:0]        raddr_prot_wdata;
wire [AW+2:0]        raddr_prot_rdata;
wire                 raddr_wen_push;
wire                 raddr_wen_pop;
wire                 raddr_fifo_full;
wire                 raddr_fifo_empty;
wire                 rdata_wen_push;
wire                 rdata_wen_pop;
wire [DW:0]          rdata_wdata;
wire [DW:0]          rdata_rdata;
wire                 rdata_fifo_empty;
wire                 rdata_fifo_full;
wire [DW-1:0]        rdata_mstr_2_axi;
wire                 rd_resp_mstr_2_axi;
wire                 rd_vld_mstr_2_axi;
wire                 wr_resp_mstr_2_axi;
wire                 rd_mstr_2_axi;
wire                 wr_mstr_2_axi;
wire [2:0]           ratio;
wire                 w_use_merr_resp;
wire                 wa_ready_sc;
wire                 wd_ready_sc;
wire                 ra_ready_sc;
wire [DW:0]          rd_data_slverr_sc;
wire                 rd_ready_sc;
wire                 rd_valid_sc;
wire                 b_ready_sc;
wire                 b_valid_sc;
wire                 b_resp_sc;



// instantiations

master_interface #(.AW(AW), .DW(DW)) u_master_interface (
// APB4 Master Interface Signals
.PSELx(PSELx_o),
.PCLK(PCLK_i),
.PRESETn(PRESETn_i),
.PADDR(PADDR_o),
.PENABLE(PENABLE_o),
.PWRITE(PWRITE_o),
.PPROT(PPROT_o),
.PWDATA(PWDATA_o),
.PSTRB(PSTRB_o),
.PREADY(PREADY_i),
.PRDATA(PRDATA_i),
.PSLVERR(PSLVERR_i),

// internal signals
.use_1clk(USE_1CLK),
.wr_rd_ratio(ratio),
.wa_fifo_rdata(waddr_prot_rdata),
.wa_fifo_pop(waddr_wen_pop),
.wa_fifo_empty(waddr_fifo_empty),
.wd_fifo_rdata(data_strb_rdata),
.wd_fifo_pop(data_wen_pop),
.wd_fifo_empty(data_fifo_empty),
.ra_fifo_rdata(raddr_prot_rdata),
.ra_fifo_pop(raddr_wen_pop),
.ra_fifo_empty(raddr_fifo_empty),
.rd_fifo_wdata(rdata_wdata),
.rd_fifo_push(rdata_wen_push),
.rd_fifo_full(rdata_fifo_full),
.wr_resp_2_axi(wr_resp_mstr_2_axi),
.wr_2_axi(wr_mstr_2_axi),
.rd_2_axi(rd_mstr_2_axi),
.wa_addr_prot(waddr_prot_wdata),
.wa_wen(waddr_wen_push),
.wa_ready(wa_ready_sc),
.wd_data_strb(data_strb_wdata),
.wd_wen(data_wen_push),
.wd_ready(wd_ready_sc),
.ra_addr_prot(raddr_prot_wdata),
.ra_wen(raddr_wen_push),
.ra_ready(ra_ready_sc),
.rd_data_slverr(rd_data_slverr_sc),
.rd_ready(rd_ready_sc),
.rd_valid(rd_valid_sc),
.b_ready(b_ready_sc),
.b_valid(b_valid_sc),
.b_resp(b_resp_sc)
);


csr_interface_apb #(.AW(AW), .DW(DW)) u_csr_interface_apb (
// APB2 Interface Signals
.PSELx(PSELx_i_csr),
.PCLK(PCLK_i_csr),
.PRESETn(PRESETn_i_csr),
.PENABLE(PENABLE_i_csr),
.PADDR(PADDR_i_csr),
.PWRITE(PWRITE_i_csr),
.PWDATA(PWDATA_i_csr),
.PRDATA(PRDATA_o_csr),
// internal signals
.axi_rd(raddr_wen_push),
.axi_wr(waddr_wen_push),
.mstr_rd(rd_mstr_2_axi),
.mstr_wr(wr_mstr_2_axi),
.wr_rd_ratio(ratio),
.use_merr_resp(w_use_merr_resp),
.wa(waddr_prot_rdata),
.wa_vld(waddr_wen_pop),
.wd(data_strb_rdata[31:0]),
.wd_vld(data_wen_pop),
.ra(raddr_prot_rdata),
.ra_vld(raddr_wen_pop),
.rd(rdata_wdata[31:0]),
.rd_vld(rdata_wen_push),
.mclk(PCLK_i),
.mrstn(PRESETn_i)
);


axi4lite_slave #(.AW(AW), .DW(DW)) u_axi4lite_slave (
// AXI4 Master Signals
.ACLK(ACLK_i),
.ARESETn(ARESETn_i),
// WA Channel
.AWADDR(AWADDR_i),
.AWPROT(AWPROT_i),  // will set to 000
.AWVALID(AWVALID_i),
.AWREADY(AWREADY_o),
// WD Channel
.WDATA(WDATA_i),
.WSTRB(WSTRB_i),  // will set to 1111
.WVALID(WVALID_i),
.WREADY(WREADY_o),
// WR Channel
.BRESP(BRESP_o),
.BVALID(BVALID_o),
.BREADY(BREADY_i),
// RA Channel
.ARADDR(ARADDR_i),
.ARPROT(ARPROT_i), 
.ARVALID(ARVALID_i),
.ARREADY(ARREADY_o),
// RD Channel
.RDATA(RDATA_o),
.RRESP(RRESP_o),
.RVALID(RVALID_o),
.RREADY(RREADY_i),

// internal signals
.use_1clk(USE_1CLK),
.w_addr_prot(waddr_prot_wdata),
.w_addr_wen(waddr_wen_push),
.w_addr_full(waddr_fifo_full),
.w_data_strb(data_strb_wdata),
.w_data_wen(data_wen_push),
.w_data_full(data_fifo_full),
.r_addr_prot(raddr_prot_wdata),
.r_addr_wen(raddr_wen_push),
.r_addr_full(raddr_fifo_full),
.r_data_err(rdata_rdata),
.r_data_ren(rdata_wen_pop),
.r_data_empty(rdata_fifo_empty),
.wr_resp_2_axi(wr_resp_mstr_2_axi),
.mstr_wr_2_axi(wr_mstr_2_axi),
.use_mwerr_resp(w_use_merr_resp),
.wa_ready(wa_ready_sc),
.wd_ready(wd_ready_sc),
.ra_ready(ra_ready_sc),
.rd_data_slverr(rd_data_slverr_sc),
.rd_ready(rd_ready_sc),
.rd_valid(rd_valid_sc),
.b_ready(b_ready_sc),
.b_valid(b_valid_sc),
.b_resp(b_resp_sc)
);


fifos #(.DW(DW)) u_fifos (
.s_rstn(ARESETn_i),
.s_clk(ACLK_i),
.m_rstn(PRESETn_i),
.m_clk(PCLK_i),
.wa_push(waddr_wen_push),
.wa_pop(waddr_wen_pop),
.wa_wdata(waddr_prot_wdata),
.wa_rdata(waddr_prot_rdata),
.wa_empty(waddr_fifo_empty),
.wa_full(waddr_fifo_full),
.wd_push(data_wen_push),
.wd_pop(data_wen_pop),
.wd_wdata(data_strb_wdata),
.wd_rdata(data_strb_rdata),
.wd_empty(data_fifo_empty),
.wd_full(data_fifo_full),
.ra_push(raddr_wen_push),
.ra_pop(raddr_wen_pop),
.ra_wdata(raddr_prot_wdata),
.ra_rdata(raddr_prot_rdata),
.ra_empty(raddr_fifo_empty),
.ra_full(raddr_fifo_full),
.rd_push(rdata_wen_push),
.rd_pop(rdata_wen_pop),
.rd_wdata(rdata_wdata),
.rd_rdata(rdata_rdata),
.rd_empty(rdata_fifo_empty),
.rd_full(rdata_fifo_full)
);

endmodule
