
// Name: slv_config
// Description: Slave Config  Register
// Address space is: C0F16000 with offset x010
// inital value if 0
// Read/Write
// bits [0]    use_merr_resp 
// bits [31:1] unused

module slave_config_reg(input clk,
			input rstn,
			input write,
			input [31:0] wdata,
			output [31:0] rdata,
			output reg slv_config_use_merr_resp);
   
   always @(posedge clk  or negedge rstn) begin
      if (!rstn)
        slv_config_use_merr_resp <= 1'b0;
      else
        if (write)
          slv_config_use_merr_resp <= wdata[0];
        else
          slv_config_use_merr_resp <= slv_config_use_merr_resp;
   end

   assign rdata = {31'h00000000,slv_config_use_merr_resp};
 
endmodule // slave_config_reg


