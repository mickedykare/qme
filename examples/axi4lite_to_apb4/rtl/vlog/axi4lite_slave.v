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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - AXI4-Lite Slave Interface 
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/12/15
// Notes: will plan to support 4 addr commands before holding with ready. 
// 
// ************************************************************************

module axi4lite_slave #(
parameter AW = 32,
parameter DW = 32
)
(
// AXI4 Slave Signals
  input 		ACLK,
  input			ARESETn,
// WA Channel
  input [AW-1:0]	AWADDR,
  input [2:0] 		AWPROT, 
  input	        	AWVALID,
  output	       	AWREADY,
// WD Channel
  input [DW-1:0]	WDATA,
  input [(DW/8)-1:0]	WSTRB,
  input 		WVALID,
  output		WREADY,
// WR Channel
  output reg [1:0]	BRESP,
  output		BVALID,
  input			BREADY,
// RA Channel
  input [AW-1:0]   	ARADDR,
  input [2:0]          	ARPROT,
  input       		ARVALID,
  output         	ARREADY,
// RD Channel
  output  [DW-1:0]   	RDATA,
  output  [1:0]        	RRESP,
  output               	RVALID,
  input                	RREADY,

// internal signals
input                   use_1clk,

output [AW+2:0] 	w_addr_prot,
output 			w_addr_wen,
input 			w_addr_full,

output [(DW/8)+DW-1:0] 	w_data_strb,
output 			w_data_wen,
input 			w_data_full,

output [AW+2:0] 	r_addr_prot,
output 			r_addr_wen,
input 			r_addr_full,

input  [DW:0]           r_data_err,
output                  r_data_ren,
input                   r_data_empty,

input                 	wr_resp_2_axi,
input                   mstr_wr_2_axi, 
input                   use_mwerr_resp,

input                   wa_ready,
input                   wd_ready,
input                   ra_ready,
input [DW:0]            rd_data_slverr,
output                  rd_ready,
input                   rd_valid,
output                  b_ready,
input                   b_valid,
input                   b_resp
);

// internal signals
parameter WR_IDLE    = 4'b0001;
parameter WR_IRESP   = 4'b0010;
parameter WR_WRESP   = 4'b0100;
parameter WR_MRESP   = 4'b1000;
parameter RR_IDLE    = 2'b01;
parameter RR_RESP_MC = 2'b10;
reg [3:0] wr_cstate, wr_nstate;
reg [1:0] rr_cstate, rr_nstate;

wire [DW-1:0] rdata_2_axi_s;
wire          rd_resp_2_axi_s;
reg           rd_resp_2_axi_s_d;
wire          rd_vld_2_axi_s;
wire          wr_resp_2_axi_s;
reg           wr_resp_2_axi_s_d;
wire          mstr_wr_2_axi_s;


// axi4lite_slave rtl

// WA Channel
assign w_addr_prot = {AWPROT,AWADDR};
assign w_addr_wen  = AWVALID & AWREADY;

MUX2to1 #(.DWIDTH(1)) u_mux_awready (
.di0(~w_addr_full),
.di1(wa_ready),
.sel(use_1clk),
.dout(AWREADY)
);


// WD Channel
assign w_data_strb = {WSTRB,WDATA};
assign w_data_wen  = WVALID & WREADY;

MUX2to1 #(.DWIDTH(1)) u_mux_wready (
.di0(~w_data_full),
.di1(wd_ready),
.sel(use_1clk),
.dout(WREADY)
);


// WR Channel (either next cycle response or use master side response)
assign b_ready = BREADY;

always @*
if (use_1clk)
	BRESP <= {b_resp,1'b0};
else if (wr_cstate == WR_MRESP)
	BRESP <= {wr_resp_2_axi_s_d,1'b0};
else if ((wr_cstate == WR_WRESP) && mstr_wr_2_axi_s)
	BRESP <= {wr_resp_2_axi_s,1'b0};
else
	BRESP <= 2'b00;

assign BVALID = use_1clk ? b_valid : 
                           use_mwerr_resp ? ((wr_cstate == WR_WRESP) && mstr_wr_2_axi_s) || (wr_cstate == WR_MRESP) 
                                          :  (wr_cstate == WR_IRESP);

always @(posedge ACLK or negedge ARESETn)
if (!ARESETn)
	wr_cstate <= WR_IDLE;
else
	wr_cstate <= wr_nstate;

always @*
case (wr_cstate)
WR_IDLE: if (!use_mwerr_resp && w_data_wen)
		wr_nstate <= WR_IRESP;
	else if (use_mwerr_resp && w_data_wen)
		wr_nstate <= WR_WRESP;
	else
		wr_nstate <= WR_IDLE;
WR_IRESP: if (BREADY && w_data_wen)
		wr_nstate <= WR_IRESP;
	else if (BREADY)
		wr_nstate <= WR_IDLE;
	else
		wr_nstate <= WR_IRESP;
WR_WRESP: if (mstr_wr_2_axi_s && BREADY)
		wr_nstate <= WR_IDLE;
	else
		wr_nstate <= WR_MRESP;
WR_MRESP: if (BREADY)
                wr_nstate <= WR_IDLE;
        else
                wr_nstate <= WR_MRESP;
default: wr_nstate <= WR_IDLE;
endcase

pulse_sync u_wr_resp_2_axi (
.rstn(ARESETn),
.clk(ACLK),
.d(wr_resp_2_axi),
.p(wr_resp_2_axi_s)
);

pulse_sync u_mstr_wr_2_axi (
.rstn(ARESETn),
.clk(ACLK),
.d(mstr_wr_2_axi),
.p(mstr_wr_2_axi_s)
);

always @(posedge ACLK or negedge ARESETn)
if (!ARESETn)
	wr_resp_2_axi_s_d <= 1'b0;
else if (wr_cstate == WR_IDLE)
	wr_resp_2_axi_s_d <= 1'b0;
else if (mstr_wr_2_axi_s)
	wr_resp_2_axi_s_d <= wr_resp_2_axi_s;
else
	wr_resp_2_axi_s_d <= wr_resp_2_axi_s_d;



// RA Channel
assign r_addr_prot = {ARPROT,ARADDR};
assign r_addr_wen  = ARVALID & ARREADY;

MUX2to1 #(.DWIDTH(1)) u_mux_arready (
.di0(~r_addr_full),
.di1(ra_ready),
.sel(use_1clk),
.dout(ARREADY)
);


// RD Channel
MUX2to1 #(.DWIDTH(32)) u_mux_rdata (
.di0(r_data_err[31:0]),
.di1(rd_data_slverr[31:0]),
.sel(use_1clk),
.dout(RDATA)
);

MUX2to1 #(.DWIDTH(2)) u_mux_rresp (
.di0({r_data_err[32],1'b0}),
.di1({rd_data_slverr[32],1'b0}),
.sel(use_1clk),
.dout(RRESP)
);

MUX2to1 #(.DWIDTH(1)) u_mux_rvalid (
.di0(rr_cstate == RR_RESP_MC),
.di1(rd_valid),
.sel(use_1clk),
.dout(RVALID)
);

assign r_data_ren = (rr_cstate == RR_IDLE) & ~r_data_empty;
assign rd_ready = RREADY;

always @(posedge ACLK or negedge ARESETn)
if (!ARESETn)
        rr_cstate <= RR_IDLE;
else
        rr_cstate <= rr_nstate;

always @*
case (rr_cstate)
RR_IDLE: if (!use_1clk && !r_data_empty)
                rr_nstate <= RR_RESP_MC;
        else
                rr_nstate <= RR_IDLE;
RR_RESP_MC: if (RREADY)
                rr_nstate <= RR_IDLE;
        else
                rr_nstate <= RR_RESP_MC;
default: rr_nstate <= RR_IDLE;
endcase


endmodule
