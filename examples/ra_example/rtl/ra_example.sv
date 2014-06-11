module ra_example
#(
  parameter ADDR_WIDTH=3,
  parameter DATA_WIDTH=8
)
(
  // FIELD OUTPUT PORTS
  output reg 			LDOA_mask_SYSPOR_DBB_RST_N_MASK1 ,
  output reg 			LDOB_mask_SYSPOR_DBB_RST_N_MASK1 ,
  output reg 			LDOC_mask_SYSPOR_DBB_RST_N_MASK1 ,
  output reg 			LDOF_mask_SYSPOR_DBB_RST_N_MASK1 ,
  output reg 			LDOG_mask_SYSPOR_DBB_RST_N_MASK1 ,
  output reg 			LDOH_mask_SYSPOR_DBB_RST_N_MASK1 ,
  output reg 			spare_SYSPOR_DBB_RST_N_MASK1 ,
  output reg 			LDOT_mask_SYSPOR_DBB_RST_N_MASK1 ,
  output reg 			LDOM_mask_SYSPOR_DBB_RST_N_MASK2 ,
  output reg 			LDOS_mask_SYSPOR_DBB_RST_N_MASK2 ,
  output reg 			EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2 ,
  output reg 			spare_SYSPOR_DBB_RST_N_MASK2 ,
  output reg 			BUCK2_mask_SYSPOR_DBB_RST_N_MASK2 ,
  output reg 			BUCK4_mask_SYSPOR_DBB_RST_N_MASK2 ,
  output reg 			BUCK1_mask_SYSPOR_DBB_RST_N_MASK2 ,
  output reg 			LDOP_mask_SYSPOR_DBB_RST_N_MASK2 ,
  output reg 			BUCK5_mask_SYSPOR_DBB_RST_N_MASK3 ,
  output reg [6:0] 		spare_SYSPOR_DBB_RST_N_MASK3 ,
  output reg [6:0] 		spare_SYSPOR_DBB_RST_N_MASK4 ,
  output reg 			rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4,

  // INPUT PORTS
  input wire 			LDOA_mask_SYSPOR_DBB_RST_N_MASK1_ip ,
  input wire 			LDOB_mask_SYSPOR_DBB_RST_N_MASK1_ip ,
  input wire 			LDOC_mask_SYSPOR_DBB_RST_N_MASK1_ip ,
  input wire 			LDOF_mask_SYSPOR_DBB_RST_N_MASK1_ip ,
  input wire 			LDOG_mask_SYSPOR_DBB_RST_N_MASK1_ip ,
  input wire 			LDOH_mask_SYSPOR_DBB_RST_N_MASK1_ip ,
  input wire 			spare_SYSPOR_DBB_RST_N_MASK1_ip ,
  input wire 			LDOT_mask_SYSPOR_DBB_RST_N_MASK1_ip ,
  input wire 			LDOM_mask_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire 			LDOS_mask_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire 			EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire 			spare_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire 			BUCK2_mask_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire 			BUCK4_mask_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire 			BUCK1_mask_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire 			LDOP_mask_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire 			BUCK5_mask_SYSPOR_DBB_RST_N_MASK3_ip ,
  input wire [6:0] 		spare_SYSPOR_DBB_RST_N_MASK3_ip ,
  input wire [6:0] 		spare_SYSPOR_DBB_RST_N_MASK4_ip ,
  input wire 			rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4_ip,

 // APB3 ports
  input 			pclk,
  input 			presetn,
  input [ADDR_WIDTH - 1 : 0] 	paddr,
  input 			psel,
  input 			penable,
  input 			pwrite,
  input [DATA_WIDTH-1:0] 	pwdata,
  input [((DATA_WIDTH/8)-1):0] 	pstrb,
  input [2:0] 			pprot,
  output logic [DATA_WIDTH-1:0] prdata,
  output logic 			pready,
  output logic 			pslverr
);



   // Hook this up to the registers
   generic_reg_bus_if #(ADDR_WIDTH,DATA_WIDTH) i_generic_reg_bus_if(pclk,presetn);

   apb3_to_regbus_bridge #(ADDR_WIDTH,DATA_WIDTH) i_apb3_bridge(  .pclk(pclk),
								  .presetn(presetn),
								  .paddr(paddr),
								  .psel(psel),
								  .penable(penable),
								  .pwrite(pwrite),
								  .pwdata(pwdata),
								  .pstrb(pstrb),
								  .pprot(pprot),
								  .prdata(prdata),
								  .pready(pready),
								  .pslverr(pslverr),
								  .rb_pins(i_generic_reg_bus_if));
   

   example_block_registers #(ADDR_WIDTH,DATA_WIDTH) i_example_block_registers(
									      // FIELD OUTPUT PORTS
									      .LDOA_mask_SYSPOR_DBB_RST_N_MASK1    (LDOA_mask_SYSPOR_DBB_RST_N_MASK1),
									      .LDOB_mask_SYSPOR_DBB_RST_N_MASK1    (LDOB_mask_SYSPOR_DBB_RST_N_MASK1),
									      .LDOC_mask_SYSPOR_DBB_RST_N_MASK1    (LDOC_mask_SYSPOR_DBB_RST_N_MASK1),
									      .LDOF_mask_SYSPOR_DBB_RST_N_MASK1    (LDOF_mask_SYSPOR_DBB_RST_N_MASK1),
									      .LDOG_mask_SYSPOR_DBB_RST_N_MASK1    (LDOG_mask_SYSPOR_DBB_RST_N_MASK1),
									      .LDOH_mask_SYSPOR_DBB_RST_N_MASK1    (LDOH_mask_SYSPOR_DBB_RST_N_MASK1),
									      .spare_SYSPOR_DBB_RST_N_MASK1        (spare_SYSPOR_DBB_RST_N_MASK1),
									      .LDOT_mask_SYSPOR_DBB_RST_N_MASK1    (LDOT_mask_SYSPOR_DBB_RST_N_MASK1),
									      .LDOM_mask_SYSPOR_DBB_RST_N_MASK2    (LDOM_mask_SYSPOR_DBB_RST_N_MASK2),
									      .LDOS_mask_SYSPOR_DBB_RST_N_MASK2    (LDOS_mask_SYSPOR_DBB_RST_N_MASK2),
									      .EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2 (EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2),
									      .spare_SYSPOR_DBB_RST_N_MASK2        (spare_SYSPOR_DBB_RST_N_MASK2),
									      .BUCK2_mask_SYSPOR_DBB_RST_N_MASK2   (BUCK2_mask_SYSPOR_DBB_RST_N_MASK2),
									      .BUCK4_mask_SYSPOR_DBB_RST_N_MASK2   (BUCK4_mask_SYSPOR_DBB_RST_N_MASK2),
									      .BUCK1_mask_SYSPOR_DBB_RST_N_MASK2   (BUCK1_mask_SYSPOR_DBB_RST_N_MASK2),
									      .LDOP_mask_SYSPOR_DBB_RST_N_MASK2    (LDOP_mask_SYSPOR_DBB_RST_N_MASK2),
									      .BUCK5_mask_SYSPOR_DBB_RST_N_MASK3   (BUCK5_mask_SYSPOR_DBB_RST_N_MASK3),
									      .spare_SYSPOR_DBB_RST_N_MASK3        (spare_SYSPOR_DBB_RST_N_MASK3),
									      .spare_SYSPOR_DBB_RST_N_MASK4        (spare_SYSPOR_DBB_RST_N_MASK4),
									      .rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4(rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4),

									      // INPUT PORTS
									      .LDOA_mask_SYSPOR_DBB_RST_N_MASK1_ip    (LDOA_mask_SYSPOR_DBB_RST_N_MASK1_ip),
									      .LDOB_mask_SYSPOR_DBB_RST_N_MASK1_ip    (LDOB_mask_SYSPOR_DBB_RST_N_MASK1_ip),
									      .LDOC_mask_SYSPOR_DBB_RST_N_MASK1_ip    (LDOC_mask_SYSPOR_DBB_RST_N_MASK1_ip),
									      .LDOF_mask_SYSPOR_DBB_RST_N_MASK1_ip    (LDOF_mask_SYSPOR_DBB_RST_N_MASK1_ip),
									      .LDOG_mask_SYSPOR_DBB_RST_N_MASK1_ip    (LDOG_mask_SYSPOR_DBB_RST_N_MASK1_ip),
									      .LDOH_mask_SYSPOR_DBB_RST_N_MASK1_ip    (LDOH_mask_SYSPOR_DBB_RST_N_MASK1_ip),
									      .spare_SYSPOR_DBB_RST_N_MASK1_ip        (spare_SYSPOR_DBB_RST_N_MASK1_ip),
									      .LDOT_mask_SYSPOR_DBB_RST_N_MASK1_ip    (LDOT_mask_SYSPOR_DBB_RST_N_MASK1_ip),
									      .LDOM_mask_SYSPOR_DBB_RST_N_MASK2_ip    (LDOM_mask_SYSPOR_DBB_RST_N_MASK2_ip),
									      .LDOS_mask_SYSPOR_DBB_RST_N_MASK2_ip    (LDOS_mask_SYSPOR_DBB_RST_N_MASK2_ip),
									      .EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2_ip (EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2_ip),
									      .spare_SYSPOR_DBB_RST_N_MASK2_ip        (spare_SYSPOR_DBB_RST_N_MASK2_ip),
									      .BUCK2_mask_SYSPOR_DBB_RST_N_MASK2_ip   (BUCK2_mask_SYSPOR_DBB_RST_N_MASK2_ip),
									      .BUCK4_mask_SYSPOR_DBB_RST_N_MASK2_ip   (BUCK4_mask_SYSPOR_DBB_RST_N_MASK2_ip),
									      .BUCK1_mask_SYSPOR_DBB_RST_N_MASK2_ip   (BUCK1_mask_SYSPOR_DBB_RST_N_MASK2_ip),
									      .LDOP_mask_SYSPOR_DBB_RST_N_MASK2_ip    (LDOP_mask_SYSPOR_DBB_RST_N_MASK2_ip),
									      .BUCK5_mask_SYSPOR_DBB_RST_N_MASK3_ip   (BUCK5_mask_SYSPOR_DBB_RST_N_MASK3_ip),
									      .spare_SYSPOR_DBB_RST_N_MASK3_ip        (spare_SYSPOR_DBB_RST_N_MASK3_ip),
									      .spare_SYSPOR_DBB_RST_N_MASK4_ip        (spare_SYSPOR_DBB_RST_N_MASK4_ip),
									      .rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4_ip(rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4_ip),
									      // GENERIC BUS PORTS
									      .clk   (i_generic_reg_bus_if.clk), // Register Bus Clock
									      .nreset   (i_generic_reg_bus_if.nreset), // Register Bus Reset
									      .waddr   (i_generic_reg_bus_if.waddr), // Write Address-Bus
									      .raddr   (i_generic_reg_bus_if.raddr), // Read Address-Bus
									      .wdata   (i_generic_reg_bus_if.wdata), // Write Data-Bus
									      .rdata   (i_generic_reg_bus_if.rdata), // Read Data-Bus
									      .rstrobe (i_generic_reg_bus_if.rstrobe), // Read-Strobe
									      .wstrobe (i_generic_reg_bus_if.wstrobe), // Write-Strobe
									      .raddrerr(i_generic_reg_bus_if.raddrerr), // Read-Address-Error
									      .waddrerr(i_generic_reg_bus_if.waddrerr), // Write-Address-Error
									      .wack    (i_generic_reg_bus_if.wack), // Write Acknowledge
									      .rack    (i_generic_reg_bus_if.rack)  // Read Acknowledge
);



endmodule

