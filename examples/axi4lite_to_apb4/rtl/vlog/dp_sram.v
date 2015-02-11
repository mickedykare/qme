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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - Dual Port SRAM (2 clk)
//                 synchronous 1 write port and 1 read port to same memory
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/6/15
// 
// ************************************************************************

module dp_sram #(
parameter AW = 32,
parameter DW = 32
)
(
input               wclk,
input               rclk,
input      [AW-1:0] waddr,
input      [AW-1:0] raddr,
input      [DW-1:0] wdata,
output reg [DW-1:0] rdata,
input               wen,
input               ren 
);

// define memory
reg [DW-1:0]  mem [(1<<AW)-1:0];

always @(posedge wclk)
	if (wen)
		mem[waddr] <= wdata;

always @(posedge rclk)
	if (ren)
		rdata <= mem[raddr];

endmodule
