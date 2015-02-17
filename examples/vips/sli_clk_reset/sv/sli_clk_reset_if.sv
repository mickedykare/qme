// *************************************************************************************
// Copyright 2014 Mentor Graphics Corporation
// All Rights Reserved
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
//
// bugs, enhancement requests to: avidan_efody@mentor.com
// *************************************************************************************
`include "uvm_macros.svh"
interface sli_clk_reset_if();
   bit clk,nreset;
   import uvm_pkg::*;
   

   // add check that you have the expected clock frequency.
   // 
   realtime pt,nt;
   time     period;
   

   initial begin
      #10ns;
      @(posedge clk) pt = $realtime();
      @(posedge clk);
      assert (($realtime - pt) == period) else
	`uvm_error("CLK GENERATION",$psprintf("Detected period = %t, expected %t - check timescale settings",$realtime()-pt,period));  
   end
		   

   




endinterface // sli_clk_reset_if
