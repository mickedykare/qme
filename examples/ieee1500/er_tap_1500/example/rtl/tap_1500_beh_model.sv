// Tried a very simple model 

module shift_register #(parameter size,reset_value) (input clk,
					 nreset,
					 din,					       
					 select,
					 shift_en,
					 update,
					 capture,
					 output logic dout,
					 input [size-1:0]  p_in,
					 output logic [size-1:0] p_out);
   

   logic [size-1:0] 					   register;

 
   
   always_ff @(posedge clk or negedge nreset) begin
      if (~nreset) begin
	 register <= reset_value;
	 p_out <= reset_value;
      end
      else begin
	 if (select) begin
	    if (shift_en) begin // Shift 
	       dout <= register[size-1];
	       for (int i=size-1; i >= 0 ;i--) begin
	
						register[i] <= (i>0)?register[i-1]:din;
	    		end
		end else if (update)
	      p_out <= register;
	    else if (capture) register <= p_in;
	 end
      end // else: !if(~nreset)
   end // always_ff @
   
endmodule 



module tap_1500_beh_model (er_tap_1500_if pins);

   // Defined instructions for this example
   parameter IR_SIZE=4;
   parameter DR_SIZE=125;
   
   parameter WS_BYPASS='hff;
   parameter WS_EXTEST=4'b0000;
   parameter WS_PRELOAD=4'b0001;

   // Instruction decodeder (combinational)
   typedef enum {WBY,WBR,WIR} reg_sel_t;
   logic 	serial_out_bypass,serial_out_ir,serial_out_dr;
   logic [IR_SIZE-1:0] instruction;
   logic [DR_SIZE-1:0] data;

    // Nice visualization
   typedef enum        {WS_BYPASS_INSTR=32'hf,
			WS_EXTEST_INSTR=32'h0,
			WS_PRELOAD_INSTR=32'h1} ws_instruction_t;
   ws_instruction_t  dbg_instruction;

   assign dbg_instruction = ws_instruction_t'(instruction);
   
   
   // We need to decode the serial outs from the registers
   
   always_comb begin
      if (pins.SelectWIR)
	pins.WSO=serial_out_ir;
      else begin
	 if (instruction==WS_BYPASS) pins.WSO = serial_out_bypass;
	 else
	   pins.WSO = serial_out_dr;
      end
   end
   
   
      shift_register#(1,1'bx) wby(.clk     (pins.WRCK),
				   .nreset  (pins.WRSTN),
				   .din     (pins.WSI),					       
				   .select  (instruction==WS_BYPASS & ~pins.SelectWIR),
				   .shift_en(pins.ShiftWR),
				   .update  ('0),
				   .capture ('0),
				   .dout    (serial_out_bypass),
				   .p_in    ('0),
				   .p_out   ());

   

      shift_register #(IR_SIZE,WS_BYPASS) wri(.clk     (pins.WRCK),
					      .nreset  (pins.WRSTN),
					      .din     (pins.WSI),					       
					      .select  (pins.SelectWIR),
					      .shift_en(pins.ShiftWR),
					      .update  (pins.UpdateWR),
					      .capture (pins.CaptureWR),
					      .dout    (serial_out_ir),
					      .p_in    (~instruction),
					      .p_out   (instruction));

      shift_register #(DR_SIZE,'0) wbr(.clk     (pins.WRCK),
				       .nreset  (pins.WRSTN),
				       .din     (pins.WSI),					       
				       .select  (~pins.SelectWIR),
				       .shift_en(pins.ShiftWR),
				       .update  (pins.UpdateWR),
				       .capture (pins.CaptureWR),
				       .dout    (serial_out_dr),
				       .p_in    (~data),
				       .p_out   (data));
   





endmodule // tap_1500_beh_model
