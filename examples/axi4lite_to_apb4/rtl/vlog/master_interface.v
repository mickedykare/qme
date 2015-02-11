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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - Master Interface
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/12/15
// 
// ************************************************************************

module master_interface #(
parameter AW  = 32,
parameter DW  = 32 
)
(
// APB4 Master Interface Signals
  output                PSELx,
  input                 PCLK,
  input                 PRESETn,
  output  [31:0]        PADDR,
  output		PENABLE,
  output                PWRITE,
  output  [2:0]		PPROT,
  output  [DW-1:0] 	PWDATA,
  output  [(DW/8)-1:0]	PSTRB,
  input 	        PREADY,
  input   [DW-1:0]   	PRDATA,
  input			PSLVERR,

// internal signals
  input  		 use_1clk,
  input  [2:0]           wr_rd_ratio,
  input  [AW+2:0] 	 wa_fifo_rdata,
  output 		 wa_fifo_pop,
  input  		 wa_fifo_empty,
  input  [(DW/8)+DW-1:0] wd_fifo_rdata,
  output 		 wd_fifo_pop,
  input  		 wd_fifo_empty,
  input  [AW+2:0] 	 ra_fifo_rdata,
  output 		 ra_fifo_pop,
  input 		 ra_fifo_empty,
  output [DW:0]          rd_fifo_wdata,
  output                 rd_fifo_push,
  input                  rd_fifo_full,
  output		 wr_resp_2_axi,
  output                 wr_2_axi,
  output                 rd_2_axi,
  input  [AW+2:0]        wa_addr_prot,
  input                  wa_wen,
  output                 wa_ready,
  input  [(DW/8)+DW-1:0] wd_data_strb,
  input                  wd_wen,
  output                 wd_ready,
  input  [AW+2:0]        ra_addr_prot,
  input                  ra_wen,
  output                 ra_ready,
  output [DW:0]          rd_data_slverr,
  input                  rd_ready,
  output                 rd_valid,
  input                  b_ready,
  output                 b_valid,
  output                 b_resp
);


// signal definitions
wire               n_pselx_sc;
wire [31:0]        n_paddr_sc;
wire               n_penable_sc;
wire               n_pwrite_sc;
wire [2:0]         n_pprot_sc;
wire [DW-1:0]      n_pwdata_sc;
wire [(DW/8)-1:0]  n_pstrb_sc;
wire               n_pready_sc;
wire [DW-1:0]      n_prdata_sc;
wire               n_pslverr_sc;

wire               n_pselx_mc;
wire [31:0]        n_paddr_mc;
wire               n_penable_mc;
wire               n_pwrite_mc;
wire [2:0]         n_pprot_mc;
wire [DW-1:0]      n_pwdata_mc;
wire [(DW/8)-1:0]  n_pstrb_mc;
wire               n_pready_mc;
wire [DW-1:0]      n_prdata_mc;
wire               n_pslverr_mc;


// instantiations

pinmux #(.AW(AW), .DW(DW)) u_pinmux (
// APB4 Master Interface Signals
.PSELx(PSELx),
.PADDR(PADDR),
.PENABLE(PENABLE),
.PWRITE(PWRITE),
.PPROT(PPROT),
.PWDATA(PWDATA),
.PSTRB(PSTRB),
.PREADY(PREADY),
.PRDATA(PRDATA),
.PSLVERR(PSLVERR),

// Single clock signals
.pselx_sc(n_pselx_sc),
.paddr_sc(n_paddr_sc),
.penable_sc(n_penable_sc),
.pwrite_sc(n_pwrite_sc),
.pprot_sc(n_pprot_sc),
.pwdata_sc(n_pwdata_sc),
.pstrb_sc(n_pstrb_sc),
.pready_sc(n_pready_sc),
.prdata_sc(n_prdata_sc),
.pslverr_sc(n_pslverr_sc),

// Multi clock signals
.pselx_mc(n_pselx_mc),
.paddr_mc(n_paddr_mc),
.penable_mc(n_penable_mc),
.pwrite_mc(n_pwrite_mc),
.pprot_mc(n_pprot_mc),
.pwdata_mc(n_pwdata_mc),
.pstrb_mc(n_pstrb_mc),
.pready_mc(n_pready_mc),
.prdata_mc(n_prdata_mc),
.pslverr_mc(n_pslverr_mc),

// other signals
.use_1clk(use_1clk)
);


apb_master_sc u_apb_master_sc (
// APB4 Interface Signals
.PCLK(PCLK),
.PRESETn(PRESETn),
.PSELx(n_pselx_sc),
.PENABLE(n_penable_sc),
.PADDR(n_paddr_sc),
.PPROT(n_pprot_sc),
.PWRITE(n_pwrite_sc),
.PWDATA(n_pwdata_sc),
.PSTRB(n_pstrb_sc),  // drive low for reads
.PREADY(n_pready_sc),
.PRDATA(n_prdata_sc),
.PSLVERR(n_pslverr_sc), // can tie 0 if not used

//internal Signals
.use_1clk(use_1clk),
.waddr_prot(wa_addr_prot),
.waddr_wen(wa_wen),
.waddr_ready(wa_ready),
.wdata_strb(wd_data_strb),
.wdata_wen(wd_wen),
.wdata_ready(wd_ready),
.raddr_prot(ra_addr_prot),
.raddr_wen(ra_wen),
.raddr_ready(ra_ready),
.rdata_slverr(rd_data_slverr),
.rdata_ready(rd_ready),
.rdata_valid(rd_valid),
.bready(b_ready),
.bvalid(b_valid),
.bresp(b_resp)
);


apb_master_mc u_apb_master_mc (
// APB4 Interface Signals
.PCLK(PCLK),
.PRESETn(PRESETn),
.PSELx(n_pselx_mc),
.PENABLE(n_penable_mc),
.PADDR(n_paddr_mc),
.PPROT(n_pprot_mc),
.PWRITE(n_pwrite_mc),
.PWDATA(n_pwdata_mc),
.PSTRB(n_pstrb_mc),
.PREADY(n_pready_mc),
.PSLVERR(n_pslverr_mc),
.PRDATA(n_prdata_mc),
.use_1clk(use_1clk),
.waddr_prot(wa_fifo_rdata),
.waddr_ren(wa_fifo_pop),
.waddr_fe(wa_fifo_empty),
.wdata_strb(wd_fifo_rdata),
.data_ren(wd_fifo_pop),
.data_fe(wd_fifo_empty),
.raddr_prot(ra_fifo_rdata),
.raddr_ren(ra_fifo_pop),
.raddr_fe(ra_fifo_empty),
.rdata_serr(rd_fifo_wdata),
.rdata_wen(rd_fifo_push),
.rdata_ff(rd_fifo_full),
.wr_resp_2_axi(wr_resp_2_axi),
.wr_2_axi(wr_2_axi),
.rd_2_axi(rd_2_axi),
.access_ratio(wr_rd_ratio)
);

endmodule
