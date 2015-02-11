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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - APB Slave Interface 
//			Interface to Config/Status Register
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/6/15
// 
// ************************************************************************

module apb_slave_int (
// APB Interface Signals
input             PSELx,
input             PCLK,
input             PRESETn,
input             PENABLE,
input      [31:0] PADDR,
input             PWRITE,
input      [31:0] PWDATA,
output     [31:0] PRDATA,

//internal Signals
output        wen,
output [31:0] waddr,
output [31:0] wdata,
output        ren,
output [31:0] raddr,
input  [31:0] rdata
);

// signal definitions
reg pselx_d;
reg penable_d;
reg pwrite_d;

// Convert APB signals to config/status bus 
always @(posedge PCLK or negedge PRESETn)
if (!PRESETn) begin
	pselx_d   <= 1'b0;
	penable_d <= 1'b0;
	pwrite_d  <= 1'b0;
end else begin
        pselx_d   <= PSELx;
        penable_d <= PENABLE;
        pwrite_d  <= PWRITE;

end

assign wen    = (pselx_d && PSELx && !penable_d && PENABLE &&  pwrite_d &&  PWRITE);
assign waddr  = PADDR;
assign wdata  = PWDATA;
assign ren    = (pselx_d && PSELx && !penable_d && PENABLE && !pwrite_d && !PWRITE);
assign raddr  = PADDR;
assign PRDATA = rdata;

endmodule
