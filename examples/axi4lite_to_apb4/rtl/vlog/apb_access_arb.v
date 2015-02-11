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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - APB Access Arbiter 
//                 Arbitrates between read/write access channels
//                 when data is available from both
//                 000 -  1 rd per 1 wr 
//                 001 -  1 rd per 1 wr
//                 010 -  2 rd per 1 wr
//                 011 -  3 rd per 1 wr
//                 100 -  1 wr per 1 rd
//                 101 -  1 wr per 1 rd
//                 110 -  2 wr per 1 rd
//                 111 -  3 wr per 1 rd
//                 If only 1 side is ready it gets serviced
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/8/15
// 
// ************************************************************************

module apb_access_arb (
input       rstn,
input       clk,
input [2:0] ratio,
input       ra_avail,
input       rd_avail,
input       wr_avail,
input       rd,
input       wr, 
output reg  rd_en,
output reg  wr_en
);


// definitions
parameter IDLE    = 5'b00001;
parameter RSETUP  = 5'b00010;
parameter RACTIVE = 5'b00100; 
parameter WSETUP  = 5'b01000;
parameter WACTIVE = 5'b10000;

reg [4:0] cstate, nstate;

wire cmd;
reg [1:0] cmd_cnt;
wire both_avail;
wire r_avail;

// logic
assign cmd = ratio[2] ? wr : rd;

always @(posedge clk or negedge rstn)
if (!rstn)
	cmd_cnt <= 2'b00;
else
	if (cstate == IDLE)
		cmd_cnt <= 2'b00;
	else if (ratio[1:0] <= 2'b01)
		cmd_cnt <= 2'b00;
	else if (cmd_cnt == ratio[1:0])
		cmd_cnt <= 2'b00;
	else if (cmd)
		cmd_cnt <= cmd_cnt + 1;
	else
		cmd_cnt <= cmd_cnt;

always @(posedge clk or negedge rstn)
if (!rstn)
	cstate <= IDLE;
else
	cstate <= nstate;

assign r_avail      = ra_avail & rd_avail;
assign both_avail   = ra_avail & wr_avail;

always @*
case (cstate)
IDLE: if (r_avail && !wr_avail)
		nstate <= RACTIVE;
	else if (!r_avail && wr_avail)
		nstate <= WACTIVE;
	else if (both_avail && ratio[2])
		nstate <= WACTIVE;
	else if (both_avail && !ratio[2])
		nstate <= RACTIVE;
	else
		nstate <= IDLE;
RSETUP: if (rd || wr)
		nstate <= RACTIVE;
	else
		nstate <= RSETUP;
RACTIVE: if (r_avail && !wr_avail)
		nstate <= RSETUP;
	else if (!r_avail && wr_avail)
		nstate <= WSETUP;
	else if (both_avail && ratio[2])
		nstate <= WSETUP;
	else if (both_avail && !ratio[2] && (ratio[1:0] <= 2'b01))
		nstate <= WSETUP;
	else if (both_avail && !ratio[2] && (cmd_cnt == ratio[1:0]))
		nstate <= WSETUP;
	else if (both_avail && !ratio[2] && (cmd_cnt <= ratio[1:0]))
		nstate <= RSETUP;
	else
		nstate <= IDLE;
WSETUP: if (rd || wr)
		nstate <= WACTIVE;
	else
		nstate <= WSETUP;
WACTIVE: if (r_avail && !wr_avail)
                nstate <= RSETUP;
        else if (!r_avail && wr_avail)
                nstate <= WSETUP;
        else if (both_avail && !ratio[2])
                nstate <= RSETUP;
        else if (both_avail && ratio[2] && (ratio[1:0] <= 2'b01))
                nstate <= RSETUP;
        else if (both_avail && ratio[2] && (cmd_cnt == ratio[1:0]))
                nstate <= RSETUP;
        else if (both_avail && ratio[2] && (cmd_cnt <= ratio[1:0]))
                nstate <= WSETUP;
        else
                nstate <= IDLE;
default: nstate <= IDLE;
endcase

always @*
if (cstate == IDLE)
	if ((r_avail & ~wr_avail) | (~ratio[2] & both_avail) )
		rd_en <= 1'b1;
	else
		rd_en <= 1'b0;
else if (cstate == RSETUP)
	if (rd || wr)
		rd_en <= 1'b1;
	else
		rd_en <= 1'b0;
else
	rd_en <= 1'b0;

always @*
if (cstate == IDLE)
        if ((~ra_avail & wr_avail) | (ratio[2] & both_avail))
                wr_en <= 1'b1;
        else
                wr_en <= 1'b0;
else if (cstate == WSETUP)
        if (rd || wr)
                wr_en <= 1'b1;
        else
                wr_en <= 1'b0;
else
        wr_en <= 1'b0;


endmodule
