module clock_reset (output bit clk,reset_n);

  timeunit 1ps;
  timeprecision 1ps;
  
  initial begin
    reset_n = 0;
    repeat(30) begin
      @ (posedge clk);
    end
    reset_n = 1;
  end

  initial begin
    clk = 0;
    forever begin
      #750 clk = ~clk;
    end
  end
     
endmodule: clock_reset

