// No guarantees, quick and dirty implementation of bus interface
interface generic_reg_bus_if #(parameter ADDR_WIDTH,parameter DATA_WIDTH)(logic clk,nreset);

  logic [ADDR_WIDTH-1:0] waddr   ;// Write Address-Bus
  logic [ADDR_WIDTH-1:0] raddr   ; // Read Address-Bus
  logic [DATA_WIDTH-1:0] wdata   ; // Write Data-Bus
  logic [DATA_WIDTH-1:0] rdata   ; // Read Data-Bus
  logic rstrobe  ; // Read-Strobe
  logic wstrobe ; // Write-Strobe
  logic raddrerr; // Read-Address-Error
  logic waddrerr; // Write-Address-Error
  logic wack     ; // Write Acknowledge
  logic rack    ;  // Read Acknowledge

 // Some nice checks.

   property p_not_at_the_same_time(a,b);
      @(posedge clk) disable iff(~nreset)
	(a==0 & b==0)| (a!=b);
   endproperty

   a_strobe:assert property(p_not_at_the_same_time(rstrobe,wstrobe));
   a_ack:assert property(p_not_at_the_same_time(wack,rack));
   a_error:assert property(p_not_at_the_same_time(raddrerr,waddrerr));
endinterface


module apb3_to_regbus_bridge #(int ADDR_WIDTH,int DATA_WIDTH)(   input  pclk,
								 input 			      presetn,
								 input [ADDR_WIDTH - 1 : 0]   paddr,
								 input 			      psel,
								 input 			      penable,
								 input 			      pwrite,
								 input [DATA_WIDTH-1:0]       pwdata,
								 input [((DATA_WIDTH/8)-1):0] pstrb,
								 input [2:0] 		      pprot,
								 output logic [DATA_WIDTH-1:0]      prdata,
								 output logic		      pready,
								 output logic		      pslverr,
											      // Generic bus interface to register
								 generic_reg_bus_if rb_pins);
   
   // Used to decode bus control signals
   
   typedef enum 									      { IDLE=0,SETUP=2,ACCESS=3,UNKNOWN=1} state_t;
   
   integer 										   wait_count = 0;
   bit 											   slverr     = 1'b0;

   


   state_t state=state_t'({psel,penable} );
   

   
   // Evaluate cycle accurate bus controls for protocol
   always_comb rb_pins.raddr=paddr;
   always_comb rb_pins.waddr=paddr;
   always_comb rb_pins.wdata=pwdata;
   always_comb prdata = rb_pins.rdata;
   always_comb pslverr = rb_pins.raddrerr|rb_pins.waddrerr;
   

   
   always @(posedge pclk or negedge presetn) begin
      
      if (presetn !== 1'b1) begin
	 pready  <= 1'b0;
//	 pslverr <= 1'b0;
//	 prdata  <= 0;
	 rb_pins.rstrobe<=0;
	 rb_pins.wstrobe <=0;
      end
      
      else begin
	 
	 // Conceptual state-machine to decode bus protocol transitions
	 case( state )
           IDLE  : 
             begin
		pready  <= 1'b0;
//		pslverr <= 1'b0;
//		prdata <= 0;
		rb_pins.rstrobe<=0;
		rb_pins.wstrobe <=0;
             end
	   
           SETUP, ACCESS  : begin 
              pready  <= (wait_count)? 1'b0 : 1'b1;
//              pslverr <= (wait_count)? 1'b0 : slverr;
              if(wait_count)
                wait_count--;
	      
              if (~pwrite) begin
		 // Read
		 rb_pins.rstrobe<=1;
		 rb_pins.wstrobe <=1;
	      end
              else begin
		 // write
                 if(!wait_count)
		   begin
		      rb_pins.wstrobe<=1;
		      rb_pins.rstrobe<=0;
		   end 
	      end // else: !if(~pwrite)
	      
	   end // case: SETUP, ACCESS
	   
           endcase // case ( state )
	 
    end 
  end 
endmodule

