// Name: axi_stat
// Description: Slave RD/WR Status
// Address space is: C0F16000 with offset x000
// inital value if 0
// read to clear
// bits [9:0]   wr_cnt
// bits [19:10] rd_cnt
// bits [31:20] unused
module axi_stat_reg(input clk,
		    input rstn,
		    input read,
		    input axi_rd_sync,
		    input axi_wr_sync,
		    output [31:0] rdata);
   
   
   reg [9:0] 			  axi_stat_rd_cnt,axi_stat_wr_cnt;

   assign rdata = {12'h000,axi_stat_rd_cnt,axi_stat_wr_cnt} ;
   
   
		  
     always @(posedge clk  or negedge rstn) begin
       if (!rstn)
	 axi_stat_rd_cnt <= 10'b0000000000;
       else 
	 if (read)
	   axi_stat_rd_cnt <= 10'b0000000000;
	 else
	   if (axi_rd_sync)
	     axi_stat_rd_cnt <= axi_stat_rd_cnt + 1;
	   else
	     axi_stat_rd_cnt <= axi_stat_rd_cnt;
     end // always @ (posedge clk  or negedge rstn)
   
   always @(posedge clk  or negedge rstn) begin
      if (!rstn)
	axi_stat_wr_cnt <= 10'b0000000000;
      else 
	if (read)
	  axi_stat_wr_cnt <= 10'b0000000000;
	else
	  if (axi_wr_sync)
            axi_stat_wr_cnt <= axi_stat_wr_cnt + 1;
	  else
            axi_stat_wr_cnt <= axi_stat_wr_cnt;
   end // always @ (posedge clk  or negedge rstn)

endmodule // axi_stat_reg
