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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - FIFO wrapper 
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/8/15
// 
// ************************************************************************

module fifos #(
parameter DW  = 32 
)
(
input                  s_rstn,
input                  s_clk,
input                  m_rstn,
input                  m_clk,
input                  wa_push,
input                  wa_pop,
input  [DW+2:0]        wa_wdata,
output [DW+2:0]        wa_rdata,
output                 wa_empty,
output                 wa_full,
input                  wd_push,
input                  wd_pop,
input  [(DW/8)+DW-1:0] wd_wdata,
output [(DW/8)+DW-1:0] wd_rdata,
output                 wd_empty,
output                 wd_full,
input                  ra_push,
input                  ra_pop,
input  [DW+2:0]        ra_wdata,
output [DW+2:0]        ra_rdata,
output                 ra_empty,
output                 ra_full,
input                  rd_push,
input                  rd_pop,
input  [DW:0]          rd_wdata,
output [DW:0]          rd_rdata,
output                 rd_empty,
output                 rd_full
);

// FIFO instantiations
dp_fifo #(.AW(2), .DW(DW+3)) u_wafifo (
.wrstn(s_rstn),
.wclk(s_clk),
.rrstn(m_rstn),
.rclk(m_clk),
.push(wa_push),
.pop(wa_pop),
.wdata(wa_wdata),
.rdata(wa_rdata),
.empty(wa_empty),
.full(wa_full)
);

dp_fifo #(.AW(2), .DW((DW/8)+DW)) u_wdfifo (
.wrstn(s_rstn),
.wclk(s_clk),
.rrstn(m_rstn),
.rclk(m_clk),
.push(wd_push),
.pop(wd_pop),
.wdata(wd_wdata),
.rdata(wd_rdata),
.empty(wd_empty),
.full(wd_full)
);

dp_fifo #(.AW(2), .DW(DW+3)) u_rafifo (
.wrstn(s_rstn),
.wclk(s_clk),
.rrstn(m_rstn),
.rclk(m_clk),
.push(ra_push),
.pop(ra_pop),
.wdata(ra_wdata),
.rdata(ra_rdata),
.empty(ra_empty),
.full(ra_full)
);

dp_fifo #(.AW(2), .DW(DW+1)) u_rdfifo (
.wrstn(m_rstn),
.wclk(m_clk),
.rrstn(s_rstn),
.rclk(s_clk),
.push(rd_push),
.pop(rd_pop),
.wdata(rd_wdata),
.rdata(rd_rdata),
.empty(rd_empty),
.full(rd_full)
);

endmodule
