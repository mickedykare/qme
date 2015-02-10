interface vsbif_if (input clk,nreset);
   import rr_pkg::*;
   
   logic [Sel_width-1:0] channel;
   logic [No_of_channels -1:0] rqst,ack;
   logic [No_of_channels -1:0] vsbdatavec [datawidth-1:0];
   logic [No_of_channels -1:0] vsbaddrvec [addrwidth-1:0];
   logic [datawidth-1:0]       ivsbdata;
   logic [addrwidth-1:0]       ivsbaddr;
   logic 		       ivsbwr;
   
   
   

   modport slave_mp(
    input 		   clk,nreset,
    input 		   rqst,
		    input vsbdatavec,
		    input vsbaddrvec,
    output 		   ack,
    output 		   ivsbdata,
    output 		   ivsbaddr,
    output 		   ivsbwr);
   
endinterface // pins


module vsbif(vsbif_if.slave_mp pins);
      import rr_pkg::*;
   logic [No_of_channels-1:0] bs3;
   logic [Sel_width-1:0] next,current,channel;
   
   assign      channel = current -1;
   

   always_ff @(posedge pins.clk or negedge pins.nreset) begin
      if (~pins.nreset) current = 0;
      else
	current <= next;
   end



   always_ff @(posedge pins.clk or negedge pins.nreset) begin
      if (~pins.nreset) 
	pins.ack = '0;
      else
	for(int i=0;i<No_of_channels;i++) 
	   if (pins.rqst[i] & (channel  == i)  )
	     pins.ack[i] <= 1'b1;
	   else
	     pins.ack[i] <= 1'b0;
   end

always_comb begin
   bs3 = {pins.rqst,pins.rqst} >> current;
      //Current channel is now LBS. Rotate one step more to make it 'last'.
end




   
   // Prio encode
   always_comb begin
      for (int i= 1;i <= No_of_channels;i++) begin
	if (bs3[i-1]) begin
	   next = current + i;
	   break;
	end
	else next = current;
      end
   end
   


   always_ff @(posedge pins.clk or negedge pins.nreset) begin
      if (!pins.nreset) begin
	 pins.ivsbdata <= '0;
	 pins.ivsbaddr <= '0;
	 pins.ivsbwr <= '0;
	 
      end
      else
	if (pins.ack[channel] )
	  begin
	     pins.ivsbdata <= pins.vsbdatavec[channel];
	     pins.ivsbaddr <= pins.vsbaddrvec[channel];
	     pins.ivsbwr <= '1;
	  end
	else
	  begin
	     pins.ivsbdata <= '0;
	     pins.ivsbaddr <= '0;
	     pins.ivsbwr <= '0;
	  end
	  
   end // always_ff @ (posedge pins.clk or negedge pins.nreset)



endmodule // vsbif
