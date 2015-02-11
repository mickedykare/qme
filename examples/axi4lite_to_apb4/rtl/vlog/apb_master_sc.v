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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - APB4 Master Interface
//                 Single clock bridge - read has priority when both
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/11/15
// 
// ************************************************************************

module apb_master_sc (
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
input             waddr_wen,
output            waddr_ready,
input      [35:0] wdata_strb,
input             wdata_wen,
output            wdata_ready,
input      [34:0] raddr_prot,
input             raddr_wen,
output            raddr_ready,
output reg [32:0] rdata_slverr,
input             rdata_ready,
output reg        rdata_valid,
input             bready,
output            bvalid,
output reg        bresp
);

// signal definition 
`include "defines.h"

state cstate, nstate;
reg [34:0] waddr_prot_r;
reg [35:0] wdata_strb_r;
reg [34:0] raddr_prot_r;
reg wa_active;
reg wd_active;
reg ra_active;
reg b_active;
wire apb_wr;
wire apb_rd;


// design code 

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
	waddr_prot_r <= 35'd0; 
else
	if (waddr_wen && use_1clk)
		waddr_prot_r <= waddr_prot;
	else
		waddr_prot_r <= waddr_prot_r;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        wdata_strb_r <= 36'd0;
else
        if (wdata_wen && use_1clk)
                wdata_strb_r <= wdata_strb;
        else
                wdata_strb_r <= wdata_strb_r;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        bresp <= 1'b0;
else
        if (apb_wr && use_1clk)
                bresp <= PSLVERR;
        else
                bresp <= bresp;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        raddr_prot_r <= 35'd0;
else
        if (raddr_wen && use_1clk)
                raddr_prot_r <= raddr_prot;
        else
                raddr_prot_r <= raddr_prot_r;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        rdata_slverr <= 33'd0;
else
        if (apb_rd && use_1clk)
                rdata_slverr <= {PSLVERR,PRDATA};
	else if (rdata_ready)
		rdata_slverr <= 33'd0;
        else
                rdata_slverr <= rdata_slverr;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        wa_active <= 1'b0;
else
        if (apb_wr && !waddr_wen)
                wa_active <= 1'b0;
	else if (waddr_wen && use_1clk)
		wa_active <= 1'b1;
        else
		wa_active <= wa_active;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        wd_active <= 1'b0;
else
        if (apb_wr && !wdata_wen)
                wd_active <= 1'b0;
	else if (wdata_wen && use_1clk)
		wd_active <= 1'b1;
        else
                wd_active <= wd_active;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        b_active <= 1'b0;
else
        if (apb_wr && bready)
                b_active <= 1'b0;
	else if (bready && b_active)
		b_active <= 1'b0;
        else if (apb_wr && !bready && use_1clk)
                b_active <= 1'b1;
        else
                b_active <= b_active;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        ra_active <= 1'b0;
else
        if (apb_rd && !raddr_wen)
                ra_active <= 1'b0;
	else if (raddr_wen && use_1clk)
		ra_active <= 1'b1;
        else
                ra_active <= ra_active;

assign waddr_ready = ~wa_active | (wa_active & apb_wr);
assign wdata_ready = ~wd_active | (wd_active & apb_wr & bready);
assign bvalid     =  b_active  | (bready   & apb_wr);
assign raddr_ready = ~ra_active | (ra_active & apb_rd);

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
        rdata_valid <= 1'b0;
else
	if (apb_rd && use_1clk)
		rdata_valid <= 1'b1;
	else if (rdata_ready)
		rdata_valid <= 1'b0;
        else
                rdata_valid <= rdata_valid;


assign PSELx   = (cstate != IDLE);
assign PWRITE  = (cstate == WSETUP)  | (cstate == WACTIVE);
assign PENABLE = (cstate == WACTIVE) | (cstate == RACTIVE);
assign PPROT  = PWRITE ? waddr_prot_r[34:32] : raddr_prot_r[34:32];
assign PADDR  = PWRITE ? waddr_prot_r[31:0]  : raddr_prot_r[31:0];
assign PSTRB  = PWRITE ? wdata_strb_r[35:32] : 4'b0000;
assign PWDATA = wdata_strb_r[31:0];

assign apb_rd     = PSELx & PENABLE & ~PWRITE & PREADY;
assign apb_wr     = PSELx & PENABLE &  PWRITE & PREADY;

always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
	cstate <= IDLE;
else
	cstate <= nstate;

always @*
case (cstate)
IDLE : if (raddr_wen && use_1clk)
		nstate <= RSETUP;
	else if (waddr_wen && wdata_wen && use_1clk)
		nstate <= WSETUP;
	else if (waddr_wen && wd_active && use_1clk)
		nstate <= WSETUP;
	else if (wdata_wen && wa_active && use_1clk)
		nstate <= WSETUP;
	else
		nstate <= IDLE; 
WSETUP : nstate <= WACTIVE;
WACTIVE: if (!PREADY)
		nstate <= WACTIVE;
	 else if (ra_active)
		nstate <= RSETUP;
         else if (wa_active && wd_active && waddr_wen && wdata_wen)
		nstate <= WSETUP;
         else
		nstate <= IDLE;
RSETUP : nstate <= RACTIVE;
RACTIVE: if (!PREADY)
                nstate <= RACTIVE;
         else if (wa_active && wd_active)
                nstate <= WSETUP;
         else if (ra_active && raddr_wen)
                nstate <= RSETUP;
         else
                nstate <= IDLE;
default: nstate <= IDLE;
endcase


endmodule
