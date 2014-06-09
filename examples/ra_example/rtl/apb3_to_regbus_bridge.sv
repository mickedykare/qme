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

   property p_strobe_one_cycle(strobe);
      @(posedge clk) disable iff(~nreset)
	$rose(strobe)|=>~strobe;
   endproperty
      
   a_rstrobe_only_one_cycle:assert property(p_strobe_one_cycle(rstrobe));
   a_wstrobe_only_one_cycle:assert property(p_strobe_one_cycle(wstrobe));
   

   a_strobe_not_at_the_same_time:assert property(p_not_at_the_same_time(rstrobe,wstrobe));
   a_ack_not_at_the_same_time:assert property(p_not_at_the_same_time(wack,rack));
   a_error_not_at_the_same_time:assert property(p_not_at_the_same_time(raddrerr,waddrerr));
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
   
   typedef enum { IDLE=0,SETUP=2,ACCESS=3,UNKNOWN=1} state_t;
   

   state_t state,state_d;
   logic 	mainstrobe;
  

   always_comb state=state_t'({psel,penable} );
   
   // Evaluate cycle accurate bus controls for protocol
   always_comb rb_pins.raddr=paddr;
   always_comb rb_pins.waddr=paddr;
   always_comb rb_pins.wdata=pwdata;
   always_comb prdata = rb_pins.rdata;
   always_comb pslverr = (rb_pins.raddrerr|rb_pins.waddrerr) & psel&penable&pready;

   
   // We need to detect pos edge of ACCESS
   always @(posedge pclk or negedge presetn) begin
      if (presetn !== 1'b1) begin
	 state_d <= IDLE;
      end
      else begin
	 state_d <= state;
      end
   end
   always_comb mainstrobe = (state==ACCESS) & (state_d == SETUP);
   
   
   always_comb rb_pins.rstrobe = mainstrobe & ~pwrite;
   always_comb rb_pins.wstrobe = mainstrobe & pwrite;
   

   

   

   
   always @(posedge pclk or negedge presetn) begin
      
      if (presetn !== 1'b1) begin
	 pready  <= 1'b0;
      end
      else begin
              pready  <= rb_pins.wack|rb_pins.rack;
      end 
   end
   
endmodule

