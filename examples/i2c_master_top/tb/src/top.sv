`timescale 1ns / 10ps

module top();
   import uvm_pkg::*;
   import mgc_i2c_v2_1_pkg::*;
   import mvc_pkg::*;
   import i2c_tb_pkg::*;
   
   bit  clk;
   bit  rstn;
   tri1 scl,sda;
   
   // generate clock
   initial begin
      clk = 0;
      forever begin
	 #5ns;
	 clk = ~clk;
      end
   end
   
   // Generate reset
   initial begin
      rstn<=0;
      repeat(5) @(posedge clk);
      rstn<=1;
   end
   
   // Instantiate the interfaces we need:
   // Wishbone
   wb_if#(32,8) i_wb_if(.clk(clk),.rstn(rstn));
   
   // Instantiate the I2C interface.
   mgc_i2c    i_i2c_if (.isample_clk(clk));


   // Instantiate an interrupt handler (used to start ISR)
   simple_irq_if i_simple_irq_if(clk,rstn);
   
   // We need an interrupt interface to reuse the
   // This is the DUT
   i2c_master_top dut (// wishbone interface
			   .wb_clk_i(clk),
			   .nreset_i(rstn),
			   .wb_adr_i(i_wb_if.adr[2:0]),
			   .wb_dat_i(i_wb_if.dout),
			   .wb_dat_o(i_wb_if.din),
			   .wb_we_i(i_wb_if.we),
			   .wb_stb_i(~i_wb_if.adr[3]),
			   .wb_cyc_i(i_wb_if.cyc),
			   .wb_ack_o(i_wb_if.ack),
			   .wb_inta_o(), // Interrupt request
			   // i2c signal
			   .scl_pad_i(i_i2c_if.sSCLH), // Serial Clock from slave
			   .scl_pad_o(scl0_o),
			   .scl_padoen_o(scl0_oen),
			   .sda_pad_i(i_i2c_if.sSDAH),
			   .sda_pad_o(sda0_o),
			   .sda_padoen_o(sda0_oen)
			   );
   

   // Combine i2c signals to pads

   // Signals driven by the controller
   tri1 mSCLH,mSDAH;
   

   assign mSCLH = (scl0_oen == 0) ? scl0_o:1'bZ;
   assign mSDAH = (sda0_oen == 0) ? sda0_o:1'bZ;
   assign i_i2c_if.mSCLH = mSCLH;
   
   assign i_i2c_if.mSDAH = mSDAH;
   

   initial begin
        uvm_config_db #(virtual wb_if #(WB_AWIDTH,WB_DWIDTH))::set( null , "uvm_test_top" , "WB_IF" , i_wb_if);
        uvm_config_db #(virtual simple_irq_if)::set( null , "uvm_test_top" , "SIMPLE_IRQ_IF" , i_simple_irq_if);
        uvm_config_db #(virtual mgc_i2c)::set( null , "uvm_test_top" , "I2C_INTERFACE" ,i_i2c_if );
        run_test("i2c_base_test"); //Default test that is run.
   end
   
   
	  

endmodule



