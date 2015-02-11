// Name: sample 
// Description: Register of samples transactions
// Address space is: C0F16000 with offset xBAC
// inital value if 0
// Read Only
// bits [31:0] reg 

module sample_reg(input clk,
		  input rstn,
		  input read,
		  output [31:0] rdata,
		  input [31:0] sample_data);
   
   reg [31:0] 			     sample_reg;
   

   
   always @(posedge clk  or negedge rstn)
     if (!rstn)
       sample_reg <= 32'h00000000;
     else
       if (read)
         sample_reg <= sample_data;
       else
         sample_reg <= sample_reg;
   

   assign rdata = sample_reg;
   

endmodule



