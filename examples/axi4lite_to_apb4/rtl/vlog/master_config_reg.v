
// Name: mst_config
// Description: Master Config Register
// Address space is: C0F16000 with offset x020
// inital value if 0
// Read/Write
// bits [2:0]   wr_rd_ratio 
// bits [31:20] unused


module master_config_reg(input clk,
			input rstn,
			input write,
			input [31:0] wdata,
			output [31:0] rdata,
			 output reg [2:0] mst_config_wr_rd_ratio);

   assign rdata =    {29'h00000000,mst_config_wr_rd_ratio} ;
   
   always @(posedge clk  or negedge rstn)
     if (!rstn)
       mst_config_wr_rd_ratio <= 3'b000;
     else
       if (write)
         mst_config_wr_rd_ratio <= wdata[2:0];
       else
         mst_config_wr_rd_ratio <= mst_config_wr_rd_ratio;
   
endmodule // master_config_reg



