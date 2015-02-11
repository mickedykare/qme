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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - APB4 Master Interface Multi-clk
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/12/15
// 
// ************************************************************************

module apb_master_mc (
// APB4 Interface Signals
input             PCLK,
input             PRESETn,
output            PSELx,
output            PENABLE,
output     [31:0] PADDR,
output      [2:0] PPROT,
output            PWRITE,
output     [31:0] PWDATA,
output      [3:0] PSTRB,  // drive low for reads
input             PREADY,
input      [31:0] PRDATA,
input             PSLVERR, // can tie 0 if not used

//internal Signals
input             use_1clk,
input      [34:0] waddr_prot,
output            waddr_ren,
input             waddr_fe,
input      [35:0] wdata_strb,
output            data_ren,
input             data_fe,
input      [34:0] raddr_prot,
output            raddr_ren,
input             raddr_fe,
output     [32:0] rdata_serr,
output            rdata_wen,
input             rdata_ff,
output            wr_resp_2_axi,
output            wr_2_axi,
output            rd_2_axi,
input      [2:0]  access_ratio
);

// signal definition 
`include "defines.h"
state cstate, nstate;
wire wfifo_ren;

// design code 

assign PPROT  = PWRITE ? waddr_prot[34:32] : raddr_prot[34:32];
assign PADDR  = PWRITE ? waddr_prot[31:0]  : raddr_prot[31:0];
assign PSTRB  = PWRITE ? wdata_strb[35:32] : 'b0;
assign PWDATA = wdata_strb[31:0];

assign apb_rd        = PSELx & PENABLE & ~PWRITE & PREADY;
assign apb_wr        = PSELx & PENABLE &  PWRITE & PREADY;
assign rdata_serr    = {PSLVERR,PRDATA};
assign rdata_wen     = apb_rd;
assign wr_resp_2_axi = PSLVERR;
assign wr_2_axi      = apb_wr;
assign rd_2_axi      = apb_rd;

assign PSELx   = (cstate != IDLE);
assign PWRITE  = (cstate == WSETUP)  | (cstate == WACTIVE);
assign PENABLE = (cstate == WACTIVE) | (cstate == RACTIVE);

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
	cstate <= IDLE;
else
	cstate <= nstate;

always @*
case (cstate)
IDLE  : if (wfifo_ren && !use_1clk)
		nstate <= WSETUP;
	else if (raddr_ren && !use_1clk)
		nstate <= RSETUP;
	else
		nstate <= IDLE;
WSETUP : nstate <= WACTIVE;
WACTIVE: if (!PREADY)
		nstate <= WACTIVE;
	 else if (wfifo_ren)
		nstate <= WSETUP;
         else if (raddr_ren)
		nstate <= RSETUP;
         else
		nstate <= IDLE;
RSETUP : nstate <= RACTIVE;
RACTIVE: if (!PREADY)
                nstate <= RACTIVE;
         else if (raddr_ren)
                nstate <= RSETUP;
         else if (wfifo_ren)
                nstate <= WSETUP;
         else
                nstate <= IDLE;
default: nstate <= IDLE;
endcase

apb_access_arb u_apb_access_arb (
.rstn(PRESETn),
.clk(PCLK),
.ratio(access_ratio),
.ra_avail(!raddr_fe),
.rd_avail(!rdata_ff),
.wr_avail(!waddr_fe & !data_fe),
.rd(apb_rd),
.wr(apb_wr),
.rd_en(raddr_ren),
.wr_en(wfifo_ren)
);

assign waddr_ren = wfifo_ren;
assign  data_ren = wfifo_ren;

endmodule
