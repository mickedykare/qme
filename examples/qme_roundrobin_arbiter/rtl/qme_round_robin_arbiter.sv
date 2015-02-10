//# *************************************************************************************
//# Example of a reusable, parametrized, Round Robin Arbiter
//# 
//# Copyright 2015 Mentor Graphics Corporation
//# All Rights Reserved
//#
//# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
//# MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
//#
//# *************************************************************************************
// 

module qme_roundrobin_arbiter #(parameter NO_OF_CHANNELS_P=32,SELECT_WIDTH_P=5)(input clk,
										input nreset,
										input [NO_OF_CHANNELS_P-1:0] request,
										output logic [NO_OF_CHANNELS_P-1:0] acknowledge);
   
   
   logic [NO_OF_CHANNELS_P-1:0]  bs3;
   logic [SELECT_WIDTH_P-1:0] 	 next,current,channel;
   // ##################################################################
   // Some built in assertions into the block.
   // ##################################################################

   // ##################################################################
   // We assume that when we do a request, we hold it until we get an acknowledge
   property p_hold_request_until_acknowledge(req_sig,ack_sig);
      @(posedge clk) disable iff(~nreset)
	$rose(req_sig)& ~ack_sig |-> (req_sig&ack_sig) ##[1:$] ((~req_sig)&(ack_sig));
   endproperty

   property p_release_req_on_ack(req_sig,ack_sig);
      @(posedge clk) disable iff(~nreset)
	$rose(ack_sig)& ~req_sig|=> (~ack_sig & ~req_sig);
   endproperty

   
   generate
      for (genvar i=0;i<NO_OF_CHANNELS_P;i++) begin
	 a_req_ack_proto:assume property(p_hold_request_until_acknowledge(request[i],acknowledge[i]));
	 a_req_ack_proto:assume property(p_release_req_on_ack(request[i],acknowledge[i]));
      end
   endgenerate
   // We assume that when we get an acknowledge, we release the request at once.

   
   // ##################################################################
   // 1. All inputs are always defined and the output is always defined.
   // ##################################################################
   property p_is_defined(sig);
      @(posedge clk) disable iff(~nreset)
	$isunknown(sig) ==0;
   endproperty
   
   a_request_defined:assert property(p_is_defined(request));
   a_acknowledge_defined:assert property(p_is_defined(acknowledge));
	 
      // ##################################################################
      // 2. Only one acknowledge is allowed 
      // ##################################################################
      property p_only_one_ack();
	 @(posedge clk)
	   (acknowledge != 0) |-> $countones(acknowledge) == 1;
      endproperty
      
      a_one_ack: assert property (p_only_one_ack());
	 



      // ##################################################################
      // 3. OVL Arbiter code
      // ##################################################################
	 ovl_rr_arbiter #(.width(NO_OF_CHANNELS_P)) i_ovl_arbiter(.clock(clk),
                          					  .reset(nreset),
								  .enable(nreset),
								  .priorities(0),
                        					  .reqs(request),
								  .gnts(acknowledge),
								  .fire()
								  );
 	 
	 
	 
	 
	 
	 
	 
	 

	 
	 always_ff @(posedge clk or negedge nreset) begin
	    if (~nreset) current <= 0;
	    else
	      current <= next;
	 end
   
   
   always_ff @(posedge clk or negedge nreset) begin
      if (~nreset) 
	acknowledge <= '0;
      else
	for(int i=0;i<NO_OF_CHANNELS_P;i++) 
	   if (request[i] & (channel  == i)  )
	     acknowledge[i] <= 1'b1;
	   else
	     acknowledge[i] <= 1'b0;
   end

   // Barrel shifter
   always_comb 
     bs3 = {request,request} >> current;

														
   always_comb      channel = current -1;

   // Prio encode
   always_comb begin
      for (int i= 1;i <= NO_OF_CHANNELS_P;i++) begin
	 if (bs3[i-1]) begin
	    next = current + i;
	    break;
	 end
	 else next = current;
      end
   end
endmodule // qme_round_robin_arbiter

   
 
