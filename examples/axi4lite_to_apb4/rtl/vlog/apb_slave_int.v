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

module apb_slave_int #(parameter BLOCK_START_ADDRESS=32'h0000_0000) (
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
output [11:0] waddr,
output [31:0] wdata,
output        ren,
output [11:0] raddr,
input  [31:0] rdata
);

// signal definitions
reg pselx_d;
reg penable_d;
reg pwrite_d;

   wire [31:0] masked_address;
   
   assign masked_address = (PADDR & 32'hFFFFF000);
   assign address_ok = (masked_address ==  BLOCK_START_ADDRESS);
   

   
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

   assign wen = PSELx && PENABLE && PWRITE && address_ok;
   assign ren = PSELx && PENABLE && ~PWRITE && address_ok;   

   

//assign wen    = (pselx_d && PSELx && !penable_d && PENABLE &&  pwrite_d &&  PWRITE) & address_ok;
//assign ren    = (pselx_d && PSELx && !penable_d && PENABLE && !pwrite_d && !PWRITE) & address_ok;
assign waddr  = PADDR[11:0];
assign wdata  = PWDATA;

assign raddr  = PADDR[11:0];
assign PRDATA = rdata;

endmodule
