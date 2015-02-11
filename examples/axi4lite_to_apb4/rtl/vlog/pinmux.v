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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - Master Interface Pin Mux
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/8/15
// 
// ************************************************************************

module pinmux #(
parameter AW  = 32,
parameter DW  = 32 
)
(
// APB4 Master Interface Signals
output                PSELx,
output  [31:0]        PADDR,
output		      PENABLE,
output                PWRITE,
output  [2:0]         PPROT,
output  [DW-1:0]      PWDATA,
output  [(DW/8)-1:0]  PSTRB,
input 	              PREADY,
input [DW-1:0]        PRDATA,
input		      PSLVERR,

// Single clock signals 
input                pselx_sc,
input  [31:0]        paddr_sc,
input                penable_sc,
input                pwrite_sc,
input  [2:0]         pprot_sc,
input  [DW-1:0]      pwdata_sc,
input  [(DW/8)-1:0]  pstrb_sc,
output               pready_sc,
output [DW-1:0]      prdata_sc,
output               pslverr_sc,

// Multi clock signals
input                pselx_mc,
input  [31:0]        paddr_mc,
input                penable_mc,
input                pwrite_mc,
input  [2:0]         pprot_mc,
input  [DW-1:0]      pwdata_mc,
input  [(DW/8)-1:0]  pstrb_mc,
output               pready_mc,
output [DW-1:0]      prdata_mc,
output               pslverr_mc,

// other signals
  input  		 use_1clk
);


// instantiations

MUX2to1 #(.DWIDTH(1)) u_pselx (
.di0(pselx_mc),
.di1(pselx_sc),
.sel(use_1clk),
.dout(PSELx)
);

MUX2to1 #(.DWIDTH(32)) u_paddr (
.di0(paddr_mc),
.di1(paddr_sc),
.sel(use_1clk),
.dout(PADDR)
);

MUX2to1 #(.DWIDTH(1)) u_penable (
.di0(penable_mc),
.di1(penable_sc),
.sel(use_1clk),
.dout(PENABLE)
);

MUX2to1 #(.DWIDTH(1)) u_pwrite (
.di0(pwrite_mc),
.di1(pwrite_sc),
.sel(use_1clk),
.dout(PWRITE)
);

MUX2to1 #(.DWIDTH(3)) u_pprot (
.di0(pprot_mc),
.di1(pprot_sc),
.sel(use_1clk),
.dout(PPROT)
);

MUX2to1 #(.DWIDTH(DW)) u_pwdata (
.di0(pwdata_mc),
.di1(pwdata_sc),
.sel(use_1clk),
.dout(PWDATA)
);

MUX2to1 #(.DWIDTH(DW/8)) u_pstrb (
.di0(pstrb_mc),
.di1(pstrb_sc),
.sel(use_1clk),
.dout(PSTRB)
);

DEC1to2 #(.DWIDTH(1)) u_pready (
.di(PREADY),
.sel(use_1clk),
.do0(pready_mc),
.do1(pready_sc)
);

DEC1to2 #(.DWIDTH(DW)) u_prdata (
.di(PRDATA),
.sel(use_1clk),
.do0(prdata_mc),
.do1(prdata_sc)
);

DEC1to2 #(.DWIDTH(1)) u_pslverr (
.di(PSLVERR),
.sel(use_1clk),
.do0(pslverr_mc),
.do1(pslverr_sc)
);

endmodule
