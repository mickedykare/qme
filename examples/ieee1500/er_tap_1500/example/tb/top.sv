module top;
   import uvm_pkg::*;
   import tap_1500_tb_pkg::*;
   
   // Interfaces
   er_simple_clk_reset_if i_clk_if();
   er_tap_1500_if  i_er_tap_1500_if(i_clk_if.clk,i_clk_if.nreset);

   // DUT
   tap_1500_beh_model DUT(i_er_tap_1500_if);


   initial begin
      uvm_config_db #(virtual er_simple_clk_reset_if)::set(null,"uvm_test_top","CLOCK_INTERFACE",i_clk_if);
      uvm_config_db #(virtual er_tap_1500_if)::set(null,"uvm_test_top","ER_TAP_1500_INTERFACE",i_er_tap_1500_if);
      run_test("tap_1500_base_test");
   end
   

endmodule // top
