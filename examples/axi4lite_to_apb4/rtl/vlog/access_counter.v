module access_counter#(parameter WIDTH=10)(input clk,nrst,clear,count_ena,
		      output reg [WIDTH-1:0] count);
   
   pulse_sync i_sync (
		      .rstn(nrst),
		      .clk(clk),
		      .d(count_ena),
		      .p(count_ena_sync)
		      );


   always  @(posedge clk or negedge nrst) begin
      if (~nrst)
	count <= 0;
      else begin
	 if (clear)
	   count <= 0;	   
	 else
	   count <= (count_ena_sync) ? count + 1:count;
      end
   end
endmodule // access_counter

