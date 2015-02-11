// Name: apb_stat
// Description: Master RD/WR Count Status
// Address space is: C0F16000 with offset x004
// inital value if 0
// Read to Clear
// bits [9:0]   wr_cnt
// bits [19:10] rd_cnt
// bits [31:20] unused

module apb_stat_reg(input clk,
		    input rstn,
		    input read,
		    input mstr_rd_sync,
		    input mstr_wr_sync,
		    output [31:0] rdata);
   
   
   reg [9:0] 			  apb_stat_rd_cnt,apb_stat_wr_cnt;

   assign rdata = {12'h000,apb_stat_rd_cnt,apb_stat_wr_cnt} ;
   


     always @(posedge clk  or negedge rstn) begin
	if (!rstn)
          apb_stat_rd_cnt <= 10'b0000000000;
	else if (read)
          apb_stat_rd_cnt <= 10'b0000000000;
	else
          if (mstr_rd_sync)
            apb_stat_rd_cnt <= apb_stat_rd_cnt + 1;
          else
            apb_stat_rd_cnt <= apb_stat_rd_cnt;
     end // always @ (posedge clk  or negedge rstn)
   


   always @(posedge clk  or negedge rstn) begin
      if (!rstn)
        apb_stat_wr_cnt <= 10'b0000000000;
      else 
	if (read)
          apb_stat_wr_cnt <= 10'b0000000000;
	else
          if (mstr_wr_sync)
            apb_stat_wr_cnt <= apb_stat_wr_cnt + 1;
          else
            apb_stat_wr_cnt <= apb_stat_wr_cnt;
   end // always @ (posedge clk  or negedge rstn)

   
endmodule // apb_stat_reg

   