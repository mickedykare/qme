/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE revB.2 compliant I2C Master controller Top-level  ////
////                                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/projects/i2c/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: i2c_master_top.v,v 1.12 2009-01-19 20:29:26 rherveille Exp $
//
//  $Date: 2009-01-19 20:29:26 $
//  $Revision: 1.12 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               Revision 1.11  2005/02/27 09:26:24  rherveille
//               Fixed register overwrite issue.
//               Removed full_case pragma, replaced it by a default statement.
//
//               Revision 1.10  2003/09/01 10:34:38  rherveille
//               Fix a blocking vs. non-blocking error in the wb_dat output mux.
//
//               Revision 1.9  2003/01/09 16:44:45  rherveille
//               Fixed a bug in the Command Register declaration.
//
//               Revision 1.8  2002/12/26 16:05:12  rherveille
//               Small code simplifications
//
//               Revision 1.7  2002/12/26 15:02:32  rherveille
//               Core is now a Multimaster I2C controller
//
//               Revision 1.6  2002/11/30 22:24:40  rherveille
//               Cleaned up code
//
//               Revision 1.5  2001/11/10 10:52:55  rherveille
//               Changed PRER reset value from 0x0000 to 0xffff, conform specs.
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

`include "i2c_master_defines.v"

// MGC: Register map is not really logically done. At least
// not from a verification point of view.
// Modified address map to this:
/*
 adr    Register 
 0x0
 0x1 
 0x2
 0x3
 0x4
 0x5 
 0x6
 0x7


*/ 
 
module i2c_master_top(
		      wb_clk_i,  nreset_i, wb_adr_i, wb_dat_i, wb_dat_o,
		      wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_inta_o,
		      scl_pad_i, scl_pad_o, scl_padoen_o, sda_pad_i, sda_pad_o, sda_padoen_o );
   
 
   //
   // inputs & outputs
   //
   
   // wishbone signals
   input        wb_clk_i;     // master clock input
   input        nreset_i;       // asynchronous reset
   input [2:0] 	wb_adr_i;     // lower address bits
   input [7:0] 	wb_dat_i;     // databus input
   output [7:0] wb_dat_o;     // databus output
   input        wb_we_i;      // write enable input
   input        wb_stb_i;     // stobe/core select signal
   input        wb_cyc_i;     // valid bus cycle input
   output       wb_ack_o;     // bus cycle acknowledge output
   output       wb_inta_o;    // interrupt request signal output
   
   reg [7:0] 	wb_dat_o;
   reg 		wb_ack_o;
   reg 		wb_inta_o;
   
   // I2C signals
	// i2c clock line
   input    scl_pad_i;       // SCL-line input
   output   scl_pad_o;       // SCL-line output (always 1'b0)
   output   scl_padoen_o;    // SCL-line output enable (active low)
   
   // i2c data line
   input    sda_pad_i;       // SDA-line input
   output   sda_pad_o;       // SDA-line output (always 1'b0)
   output   sda_padoen_o;    // SDA-line output enable (active low)
   
   
   //
   // variable declarations
   //

   // MGC address map definitions 
   parameter PREL_LO_ADR=3'h0;
   parameter PREL_HI_ADR=3'h1;
   parameter CTR_ADR    =3'h2;
   parameter RXR_ADR    =3'h3;
   parameter CR_ADR     =3'h4;
   parameter SR_ADR     =3'h5;
   parameter TXR_ADR    =3'h6;
   parameter UNUSED_ADR =7'h7;
   
   

   // registers
   reg [15:0] prer; // clock prescale register
   reg [ 7:0] ctr;  // control register
   reg [ 7:0] txr;  // transmit register
   wire [ 7:0] rxr;  // receive register
   reg [ 7:0]  cr;   // command register
   wire [ 7:0] sr;   // status register

   // done signal: command completed, clear command register
   wire        done;
   
   // core enable signal
   wire        core_en;
   wire        ien;

   // status register signals
   wire        irxack;
   reg 	       rxack;       // received aknowledge from slave
   reg 	       tip;         // transfer in progress
   reg 	       irq_flag;    // interrupt pending flag
   wire        i2c_busy;    // bus busy (start signal detected)
   wire        i2c_al;      // i2c bus arbitration lost
   reg 	       al;          // status register arbitration lost bit

   //
   // module body
   //
   
   // generate wishbone signals
   wire        wb_wacc = wb_we_i & wb_ack_o;
   
   // generate acknowledge output signal
   always @(posedge wb_clk_i or negedge nreset_i)
     if (~nreset_i)
       wb_ack_o <=0;
     else
     wb_ack_o <=  wb_cyc_i & wb_stb_i & ~wb_ack_o; // because timing is always honored
   
   // assign DAT_O (Reading)
   // MGC: fixed decoding to be more logical. 
   
   always @(posedge wb_clk_i)
     begin
	case (wb_adr_i) // synopsys parallel_case
	  PREL_LO_ADR : wb_dat_o <=  prer[ 7:0];
	  PREL_HI_ADR : wb_dat_o <=  prer[15:8];
	  CTR_ADR     : wb_dat_o <=  ctr;
	  RXR_ADR     : wb_dat_o <=  rxr; 
	  CR_ADR      : wb_dat_o <=  cr; 
	  SR_ADR      : wb_dat_o <=  sr;
	  TXR_ADR     : wb_dat_o <=  txr;
	  UNUSED_ADR  : wb_dat_o <=  '0;   // reserved
	endcase
     end

	// generate registers
   always @(posedge wb_clk_i or negedge nreset_i)
     if (!nreset_i)
       begin
	  prer <=  16'hffff;
	  ctr  <=   8'h0;
	  txr  <=   8'h0;
	  cr <=  8'h0;
       end
     else
       if (wb_wacc) begin
	  // MGC easier register declaration
	  case (wb_adr_i) // synopsys parallel_case
	    PREL_LO_ADR : prer [ 7:0] <=  wb_dat_i;
	    PREL_HI_ADR : prer [15:8] <=  wb_dat_i;
	    CTR_ADR     : ctr         <=  wb_dat_i;
	    TXR_ADR     : txr         <=  wb_dat_i;
	    CR_ADR      : cr <=  (core_en) ? wb_dat_i:cr;
	    default:;
	  endcase // case (wb_adr_i)
       end // if (wb_wacc)
       else begin
	  // clear command bits when done or when aribitration lost
	  cr[7:4] <= (done | i2c_al) ? 4'h0:cr[7:4];           
	  cr[2:1] <= (done | i2c_al) ? 2'b0:cr[2:1];             // reserved bits
	  cr[0]   <= (done | i2c_al) ? 1'b0:cr[0];             // clear IRQ_ACK bit
       end



	// decode command register
	wire sta  = cr[7];
	wire sto  = cr[6];
	wire rd   = cr[5];
	wire wr   = cr[4];
	wire ack  = cr[3];
	wire iack = cr[0];

	// decode control register
	assign core_en = ctr[7];
	assign ien = ctr[6];

	// hookup byte controller block
	i2c_master_byte_ctrl byte_controller (
		.clk      ( wb_clk_i     ),
		.nreset   ( nreset_i        ),
		.ena      ( core_en      ),
		.clk_cnt  ( prer         ),
		.start    ( sta          ),
		.stop     ( sto          ),
		.read     ( rd           ),
		.write    ( wr           ),
		.ack_in   ( ack          ),
		.din      ( txr          ),
		.cmd_ack  ( done         ),
		.ack_out  ( irxack       ),
		.dout     ( rxr          ),
		.i2c_busy ( i2c_busy     ),
		.i2c_al   ( i2c_al       ),
		.scl_i    ( scl_pad_i    ),
		.scl_o    ( scl_pad_o    ),
		.scl_oen  ( scl_padoen_o ),
		.sda_i    ( sda_pad_i    ),
		.sda_o    ( sda_pad_o    ),
		.sda_oen  ( sda_padoen_o )
	);

	// status register block + interrupt request signal
	always @(posedge wb_clk_i or negedge nreset_i)
	  if (!nreset_i)
	    begin
	        al       <=  1'b0;
	        rxack    <=  1'b0;
	        tip      <=  1'b0;
	        irq_flag <=  1'b0;
	    end
	  else
	    begin
	        al       <=  i2c_al | (al & ~sta);
	        rxack    <=  irxack;
	        tip      <=  (rd | wr);
	        irq_flag <=  (done | i2c_al | irq_flag) & ~iack; // interrupt request flag is always generated
	    end

	// generate interrupt request signals
	always @(posedge wb_clk_i or negedge nreset_i)
	  if (!nreset_i)
	    wb_inta_o <=  1'b0;
	  else
	    wb_inta_o <=  irq_flag && ien; // interrupt signal is only generated when IEN (interrupt enable bit is set)

	// assign status register bits
	assign sr[7]   = rxack;
	assign sr[6]   = i2c_busy;
	assign sr[5]   = al;
	assign sr[4:2] = 3'h0; // reserved
	assign sr[1]   = tip;
	assign sr[0]   = irq_flag;

endmodule
