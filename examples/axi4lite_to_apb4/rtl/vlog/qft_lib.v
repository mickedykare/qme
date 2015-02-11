// ************************************************************************
//                Copyright 2006-2015 Mentor Graphics Corporation
//                             All Rights Reserved.
// 
//                THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//              INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
//             CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                    TERMS.
// 
//  ************************************************************************
// 
//  DESCRIPTION   : AXI4Lite to APB4 Bridge - Library Modules 
//  AUTHOR        : Mark Eslinger
//  Last Modified : 1/6/15
// 
//  ************************************************************************


// 2to1 MUX 
module MUX2to1 #(parameter DWIDTH = 1) (
input  [DWIDTH-1:0] di0,
input  [DWIDTH-1:0] di1,
input               sel,
output [DWIDTH-1:0] dout
);

assign dout = sel ? di1 : di0;

endmodule


// 1to2 DECODER
module DEC1to2 #(parameter DWIDTH = 1) (
input  [DWIDTH-1:0] di,
input               sel,
output [DWIDTH-1:0] do0,
output [DWIDTH-1:0] do1
);

assign do0 = sel ? 'b0  :  di;
assign do1 = sel ?  di  : 'b0; 

endmodule


// 2DFF sync
module sync_2dff #(
parameter DW = 1
)
(
input rstn,
input clk,
input [DW-1:0] d,
output reg [DW-1:0] q
);

reg [DW-1:0] meta;

always @(posedge clk or negedge rstn)
if (!rstn) begin
	meta <= 'b0;
	q    <= 'b0;
end
else begin
        meta <= d;
        q    <= meta;
end

endmodule


// Pulse Sync (rising edge only)
module pulse_sync (
input rstn,
input clk,
input d,
output p 
);

reg meta1, meta2, meta3;

always @(posedge clk or negedge rstn)
if (!rstn) begin
        meta1 <= 1'b0;
        meta2 <= 1'b0;
        meta3 <= 1'b0;
end
else begin
        meta1 <=  d;
        meta2 <=  meta1;
        meta3 <= ~meta2;
end

assign p = meta2 & meta3;

endmodule



// DMUX sync w pulse sync
module psync_dmux #(parameter DWIDTH = 1) (
input rstn,
input clk,
input sel,
input [DWIDTH-1:0] din,
output reg [DWIDTH-1:0] dout
);

wire s_sel;

pulse_sync u1 (.rstn(rstn), .clk(clk), .d(sel), .p(s_sel) );

always @(posedge clk or negedge rstn)
if (!rstn)
	dout <= 'b0;
else
	if (s_sel)
		dout <= din;
	else
		dout <= dout;

endmodule





