`timescale 1ns/1ns

`include "fpu_pin_if_sva.sv"

module top;
   import uvm_pkg::*;
   import uvmc_pkg::*;

   import fpu_agent_pkg::*;
   import fpu_pkg::*;

   clock_reset clk_rst (clk, reset_n);
   
   bit stop = 1'b0;
   
   fpu_pin_if fpu_pins(clk, reset_n);

   fpu fpu_dut(.clk_i(fpu_pins.clk),
	       .reset_i(fpu_pins.reset),
	       .opa_i(fpu_pins.opa),
	       .opb_i(fpu_pins.opb),
	       .fpu_op_i(fpu_pins.fpu_op),
	       .rmode_i(fpu_pins.rmode),
	       .output_o(fpu_pins.outp),
	       .start_i(fpu_pins.start),
	       .ready_o(fpu_pins.ready),
	       .ine_o(fpu_pins.ine),
	       .overflow_o(fpu_pins.overflow),
	       .underflow_o(fpu_pins.underflow),
	       .div_zero_o(fpu_pins.div_zero),
	       .inf_o(fpu_pins.inf),
	       .zero_o(fpu_pins.zero),
	       .qnan_o(fpu_pins.qnan),
	       .snan_o(fpu_pins.snan));

	logic stop_signal;
	logic fpu_warning;
	logic [31:0] force_value;
	logic update_timer_counter;


	initial begin
	//   fpu_vif_object fpu_vif_cfg = new("fpu_if_cfg");
	//   fpu_vif_cfg.set_vif( fpu_pins );

		// Change from set_config_object to
		// uvm_config_db#
		// set_config_object("*", "fpu_vif", fpu_vif_cfg);
		uvm_config_db#(virtual fpu_pin_if)::set(null,"uvm_test_top.*","fpu_vif_if1",fpu_pins);
		run_test();
		stop = 1'b1;
	end

	initial begin
		update_timer_counter=10;
		force_value=0;
		stop_signal=0;
	end
   
endmodule

