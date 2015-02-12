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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - Dual Port FIFO 
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/14/15
// 
// ************************************************************************

module dp_fifo #(
parameter AW = 3,
parameter DW = 8
)
(
input           wrstn,
input           wclk,
input		rrstn,
input           rclk,
input           push,
input           pop,
input  [DW-1:0] wdata,
output [DW-1:0] rdata,
output reg      empty,
output reg      full
);


// Local signal definitions 
reg     [AW:0]          wp_binary, wp_gray;
wire    [AW:0]          wp_binary_next, wp_gray_next;

reg     [AW:0]          rp_binary, rp_gray;
wire    [AW:0]          rp_binary_next, rp_gray_next;

reg     [AW:0]          wp_sync_2r, wp_meta;
reg     [AW:0]          rp_sync_2w, rp_meta;
wire    [AW:0]          rp_sync_2w_2binary;


   // Dual Port Memory 
   dp_sram #(AW, DW) fifo_mem 
     (
      .wclk(wclk),
      .rclk(rclk),
      .waddr(wp_binary[AW-1:0]),
      .raddr(rp_binary[AW-1:0]),
      .wdata(wdata),
      .rdata(rdata),
      .wen(push),
      .ren(pop)
      );





   
   // Push/Pop Pointer Logic
   always @(posedge wclk or negedge wrstn)
     if(!wrstn)     
       wp_binary <= 'b0;
     else
       if (push)          
	 wp_binary <= wp_binary_next;
       else
	 wp_binary <= wp_binary;


   

   
   always @(posedge wclk or negedge wrstn)
     if(!wrstn)
       wp_gray <= 'b0;
     else
       if (push)
	 wp_gray <= wp_gray_next;
       else
	 wp_gray <= wp_gray;

   assign wp_binary_next = wp_binary + 'b1;
   assign wp_gray_next   = wp_binary_next ^ {1'b0, wp_binary_next[AW:1]};


   always @(posedge rclk or negedge rrstn)
     if(!rrstn)
       rp_binary <= 'b0;
     else
       if (pop)
	 rp_binary <= rp_binary_next;
       else
	 rp_binary <= rp_binary;

   always @(posedge rclk or negedge rrstn)
     if(!rrstn)
       rp_gray <= {AW+1{1'b0}};
     else
       if (pop)
	 rp_gray <= rp_gray_next;
       else
	 rp_gray <= rp_gray;

   assign rp_binary_next  = rp_binary + 'b1;
   assign rp_gray_next    = rp_binary_next ^ {1'b0, rp_binary_next[AW:1]};


   // Gray Pointer Synchronizers
   always @(posedge rclk or negedge rrstn)
     if (!rrstn) begin
	wp_meta    <= 'b0;
	wp_sync_2r <= 'b0;
     end else begin
	wp_meta    <= wp_gray;
	wp_sync_2r <= wp_meta;
     end

   always @(posedge wclk or negedge wrstn)
     if (!wrstn) begin
        rp_meta    <= 'b0;
        rp_sync_2w <= 'b0;
     end else begin
        rp_meta    <= rp_gray;
        rp_sync_2w <= rp_meta;
     end


   // Generate Full and Empty Flags 
   assign rp_sync_2w_2binary = rp_sync_2w ^ {1'b0, rp_sync_2w_2binary[AW:1]};

   always @(posedge wclk or negedge wrstn)
     if (!wrstn)
       full <= 1'b0;
     else
       full <= ((wp_binary[AW-1:0] == rp_sync_2w_2binary[AW-1:0]) & (wp_binary[AW] != rp_sync_2w_2binary[AW])) |
               (push & (wp_binary_next[AW-1:0] == rp_sync_2w_2binary[AW-1:0]) & (wp_binary_next[AW] != rp_sync_2w_2binary[AW]));

   always @(posedge rclk or negedge rrstn)
     if (!rrstn)
       empty <= 1'b1;
     else
       empty <= (wp_sync_2r == rp_gray) | (pop & (wp_sync_2r == rp_gray_next));


endmodule
