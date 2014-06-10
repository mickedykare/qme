//----------------------------------------------------------------------
//   THIS IS AUTOMATICALLY GENERATED CODE
//   Generated by Mentor Graphics' Register Assistant V4.5 (Build 2)
//----------------------------------------------------------------------
// Project         : ra_work
// File            : /home/mikaela/questa_makefile_environment/examples/ra_example/rtl/example_block_registers.v
//----------------------------------------------------------------------
// Created by      : mikaela
// Creation Date   : 10 06 2014 19:26::45
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Block           : example_block_registers
// Address Range   : 0x4
//----------------------------------------------------------------------
// Description: 
//    Register block
//----------------------------------------------------------------------

module example_block_registers
#(
  parameter ADDR_WIDTH=3,
  parameter DATA_WIDTH=8
)
(
  // FIELD OUTPUT PORTS
  output reg         LDOA_mask_SYSPOR_DBB_RST_N_MASK1    ,
  output reg         LDOB_mask_SYSPOR_DBB_RST_N_MASK1    ,
  output reg         LDOC_mask_SYSPOR_DBB_RST_N_MASK1    ,
  output reg         LDOF_mask_SYSPOR_DBB_RST_N_MASK1    ,
  output reg         LDOG_mask_SYSPOR_DBB_RST_N_MASK1    ,
  output reg         LDOH_mask_SYSPOR_DBB_RST_N_MASK1    ,
  output reg         spare_SYSPOR_DBB_RST_N_MASK1        ,
  output reg         LDOT_mask_SYSPOR_DBB_RST_N_MASK1    ,
  output reg         LDOM_mask_SYSPOR_DBB_RST_N_MASK2    ,
  output reg         LDOS_mask_SYSPOR_DBB_RST_N_MASK2    ,
  output reg         EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2 ,
  output reg         spare_SYSPOR_DBB_RST_N_MASK2        ,
  output reg         BUCK2_mask_SYSPOR_DBB_RST_N_MASK2   ,
  output reg         BUCK4_mask_SYSPOR_DBB_RST_N_MASK2   ,
  output reg         BUCK1_mask_SYSPOR_DBB_RST_N_MASK2   ,
  output reg         LDOP_mask_SYSPOR_DBB_RST_N_MASK2    ,
  output reg         BUCK5_mask_SYSPOR_DBB_RST_N_MASK3   ,
  output reg   [6:0] spare_SYSPOR_DBB_RST_N_MASK3        ,
  output reg   [6:0] spare_SYSPOR_DBB_RST_N_MASK4        ,
  output reg         rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4,

  // INPUT PORTS
  input wire         LDOA_mask_SYSPOR_DBB_RST_N_MASK1_ip    ,
  input wire         LDOB_mask_SYSPOR_DBB_RST_N_MASK1_ip    ,
  input wire         LDOC_mask_SYSPOR_DBB_RST_N_MASK1_ip    ,
  input wire         LDOF_mask_SYSPOR_DBB_RST_N_MASK1_ip    ,
  input wire         LDOG_mask_SYSPOR_DBB_RST_N_MASK1_ip    ,
  input wire         LDOH_mask_SYSPOR_DBB_RST_N_MASK1_ip    ,
  input wire         spare_SYSPOR_DBB_RST_N_MASK1_ip        ,
  input wire         LDOT_mask_SYSPOR_DBB_RST_N_MASK1_ip    ,
  input wire         LDOM_mask_SYSPOR_DBB_RST_N_MASK2_ip    ,
  input wire         LDOS_mask_SYSPOR_DBB_RST_N_MASK2_ip    ,
  input wire         EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2_ip ,
  input wire         spare_SYSPOR_DBB_RST_N_MASK2_ip        ,
  input wire         BUCK2_mask_SYSPOR_DBB_RST_N_MASK2_ip   ,
  input wire         BUCK4_mask_SYSPOR_DBB_RST_N_MASK2_ip   ,
  input wire         BUCK1_mask_SYSPOR_DBB_RST_N_MASK2_ip   ,
  input wire         LDOP_mask_SYSPOR_DBB_RST_N_MASK2_ip    ,
  input wire         BUCK5_mask_SYSPOR_DBB_RST_N_MASK3_ip   ,
  input wire   [6:0] spare_SYSPOR_DBB_RST_N_MASK3_ip        ,
  input wire   [6:0] spare_SYSPOR_DBB_RST_N_MASK4_ip        ,
  input wire         rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4_ip,

  // GENERIC BUS PORTS
  input  wire                  clock   , // Register Bus Clock
  input  wire                  reset   , // Register Bus Reset
  input  wire [ADDR_WIDTH-1:0] waddr   , // Write Address-Bus
  input  wire [ADDR_WIDTH-1:0] raddr   , // Read Address-Bus
  input  wire [DATA_WIDTH-1:0] wdata   , // Write Data-Bus
  output reg  [DATA_WIDTH-1:0] rdata   , // Read Data-Bus
  input  wire                  rstrobe , // Read-Strobe
  input  wire                  wstrobe , // Write-Strobe
  output reg                   raddrerr, // Read-Address-Error
  output reg                   waddrerr, // Write-Address-Error
  output reg                   wack    , // Write Acknowledge
  output reg                   rack      // Read Acknowledge
);

  // READ/WRITE ENABLE SIGNALS
  reg  wen_SYSPOR_DBB_RST_N_MASK1;
  reg  wen_SYSPOR_DBB_RST_N_MASK2;
  reg  wen_SYSPOR_DBB_RST_N_MASK3;
  reg  wen_SYSPOR_DBB_RST_N_MASK4;

  // MUX INPUTS FOR EACH REGISTER WITH READ ACCESS
  wire [DATA_WIDTH-1:0] rmux_SYSPOR_DBB_RST_N_MASK1;
  wire [DATA_WIDTH-1:0] rmux_SYSPOR_DBB_RST_N_MASK2;
  wire [DATA_WIDTH-1:0] rmux_SYSPOR_DBB_RST_N_MASK3;
  wire [DATA_WIDTH-1:0] rmux_SYSPOR_DBB_RST_N_MASK4;

  // DEFAULT VALUE FOR READ DATA BUS
  localparam DEF_RDATA_VAL = 8'h00;

  // ADDRESS PARAMETERS
  localparam SYSPOR_DBB_RST_N_MASK1_ADDR = 3'b000;
  localparam SYSPOR_DBB_RST_N_MASK2_ADDR = 3'b001;
  localparam SYSPOR_DBB_RST_N_MASK3_ADDR = 3'b010;
  localparam SYSPOR_DBB_RST_N_MASK4_ADDR = 3'b011;


  //----------------------------------------------------------------------
  //                    WRITE ADDRESS DECODE
  //----------------------------------------------------------------------
  always @ ( * )
  begin : write_enable
    wen_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    wen_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    wen_SYSPOR_DBB_RST_N_MASK3 <= 1'b0;
    wen_SYSPOR_DBB_RST_N_MASK4 <= 1'b0;
    waddrerr <= 1'b0;
    wack <= 1'b0;

    if (wstrobe)
    begin
      case (waddr)
        SYSPOR_DBB_RST_N_MASK1_ADDR:
        begin
          wen_SYSPOR_DBB_RST_N_MASK1 <= 1'b1;
        end
        SYSPOR_DBB_RST_N_MASK2_ADDR:
        begin
          wen_SYSPOR_DBB_RST_N_MASK2 <= 1'b1;
        end
        SYSPOR_DBB_RST_N_MASK3_ADDR:
        begin
          wen_SYSPOR_DBB_RST_N_MASK3 <= 1'b1;
        end
        SYSPOR_DBB_RST_N_MASK4_ADDR:
        begin
          wen_SYSPOR_DBB_RST_N_MASK4 <= 1'b1;
        end
        default:
        begin
          waddrerr <= 1'b1;
        end
      endcase
      wack <= 1'b1;
    end
  end


  //------------------------------------------------------------
  // Register: SYSPOR_DBB_RST_N_MASK1_REG
  //   SW Access     : read-write
  //   Address Offset: 0x0
  //   HW Access     : read-write
  // 
  // Instance: SYSPOR_DBB_RST_N_MASK1
  //   Address Offset: 0x00
  //   Reset Value   : 
  // 
  // Fields:
  //     7  LDOA_mask (SW:read-write, HW:read-write)
  //     6  LDOB_mask (SW:read-write, HW:read-write)
  //     5  LDOC_mask (SW:read-write, HW:read-write)
  //     4  LDOF_mask (SW:read-write, HW:read-write)
  //     3  LDOG_mask (SW:read-write, HW:read-write)
  //     2  LDOH_mask (SW:read-write, HW:read-write)
  //     1  spare (SW:read-write, HW:read-write)
  //     0  LDOT_mask (SW:read-write, HW:read-write)

  //------------------------------------------------------------
  //   Field: LDOA_mask                               
  //   Width: 1              , Offset: 7              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask1_reg_ldoa_mask_syspor_dbb_rst_n_mask1
    // Reset
    if ( !reset )
      LDOA_mask_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK1)
      LDOA_mask_SYSPOR_DBB_RST_N_MASK1 <= wdata[7];
    // HW:read-write
    else
      LDOA_mask_SYSPOR_DBB_RST_N_MASK1 <= LDOA_mask_SYSPOR_DBB_RST_N_MASK1_ip;
  end

  //------------------------------------------------------------
  //   Field: LDOB_mask                               
  //   Width: 1              , Offset: 6              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask1_reg_ldob_mask_syspor_dbb_rst_n_mask1
    // Reset
    if ( !reset )
      LDOB_mask_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK1)
      LDOB_mask_SYSPOR_DBB_RST_N_MASK1 <= wdata[6];
    // HW:read-write
    else
      LDOB_mask_SYSPOR_DBB_RST_N_MASK1 <= LDOB_mask_SYSPOR_DBB_RST_N_MASK1_ip;
  end

  //------------------------------------------------------------
  //   Field: LDOC_mask                               
  //   Width: 1              , Offset: 5              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask1_reg_ldoc_mask_syspor_dbb_rst_n_mask1
    // Reset
    if ( !reset )
      LDOC_mask_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK1)
      LDOC_mask_SYSPOR_DBB_RST_N_MASK1 <= wdata[5];
    // HW:read-write
    else
      LDOC_mask_SYSPOR_DBB_RST_N_MASK1 <= LDOC_mask_SYSPOR_DBB_RST_N_MASK1_ip;
  end

  //------------------------------------------------------------
  //   Field: LDOF_mask                               
  //   Width: 1              , Offset: 4              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask1_reg_ldof_mask_syspor_dbb_rst_n_mask1
    // Reset
    if ( !reset )
      LDOF_mask_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK1)
      LDOF_mask_SYSPOR_DBB_RST_N_MASK1 <= wdata[4];
    // HW:read-write
    else
      LDOF_mask_SYSPOR_DBB_RST_N_MASK1 <= LDOF_mask_SYSPOR_DBB_RST_N_MASK1_ip;
  end

  //------------------------------------------------------------
  //   Field: LDOG_mask                               
  //   Width: 1              , Offset: 3              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask1_reg_ldog_mask_syspor_dbb_rst_n_mask1
    // Reset
    if ( !reset )
      LDOG_mask_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK1)
      LDOG_mask_SYSPOR_DBB_RST_N_MASK1 <= wdata[3];
    // HW:read-write
    else
      LDOG_mask_SYSPOR_DBB_RST_N_MASK1 <= LDOG_mask_SYSPOR_DBB_RST_N_MASK1_ip;
  end

  //------------------------------------------------------------
  //   Field: LDOH_mask                               
  //   Width: 1              , Offset: 2              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask1_reg_ldoh_mask_syspor_dbb_rst_n_mask1
    // Reset
    if ( !reset )
      LDOH_mask_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK1)
      LDOH_mask_SYSPOR_DBB_RST_N_MASK1 <= wdata[2];
    // HW:read-write
    else
      LDOH_mask_SYSPOR_DBB_RST_N_MASK1 <= LDOH_mask_SYSPOR_DBB_RST_N_MASK1_ip;
  end

  //------------------------------------------------------------
  //   Field: spare                                   
  //   Width: 1              , Offset: 1              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask1_reg_spare_syspor_dbb_rst_n_mask1
    // Reset
    if ( !reset )
      spare_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK1)
      spare_SYSPOR_DBB_RST_N_MASK1 <= wdata[1];
    // HW:read-write
    else
      spare_SYSPOR_DBB_RST_N_MASK1 <= spare_SYSPOR_DBB_RST_N_MASK1_ip;
  end

  //------------------------------------------------------------
  //   Field: LDOT_mask                               
  //   Width: 1              , Offset: 0              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask1_reg_ldot_mask_syspor_dbb_rst_n_mask1
    // Reset
    if ( !reset )
      LDOT_mask_SYSPOR_DBB_RST_N_MASK1 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK1)
      LDOT_mask_SYSPOR_DBB_RST_N_MASK1 <= wdata[0];
    // HW:read-write
    else
      LDOT_mask_SYSPOR_DBB_RST_N_MASK1 <= LDOT_mask_SYSPOR_DBB_RST_N_MASK1_ip;
  end


  //------------------------------------------------------------
  // Register: SYSPOR_DBB_RST_N_MASK2_REG
  //   SW Access     : read-write
  //   Address Offset: 0x1
  //   HW Access     : read-write
  // 
  // Instance: SYSPOR_DBB_RST_N_MASK2
  //   Address Offset: 0x01
  //   Reset Value   : 
  // 
  // Fields:
  //     7  LDOM_mask (SW:read-write, HW:read-write)
  //     6  LDOS_mask (SW:read-write, HW:read-write)
  //     5  EXTBST1_mask (SW:read-write, HW:read-write)
  //     4  spare (SW:read-write, HW:read-write)
  //     3  BUCK2_mask (SW:read-write, HW:read-write)
  //     2  BUCK4_mask (SW:read-write, HW:read-write)
  //     1  BUCK1_mask (SW:read-write, HW:read-write)
  //     0  LDOP_mask (SW:read-write, HW:read-write)

  //------------------------------------------------------------
  //   Field: LDOM_mask                               
  //   Width: 1              , Offset: 7              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask2_reg_ldom_mask_syspor_dbb_rst_n_mask2
    // Reset
    if ( !reset )
      LDOM_mask_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK2)
      LDOM_mask_SYSPOR_DBB_RST_N_MASK2 <= wdata[7];
    // HW:read-write
    else
      LDOM_mask_SYSPOR_DBB_RST_N_MASK2 <= LDOM_mask_SYSPOR_DBB_RST_N_MASK2_ip;
  end

  //------------------------------------------------------------
  //   Field: LDOS_mask                               
  //   Width: 1              , Offset: 6              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask2_reg_ldos_mask_syspor_dbb_rst_n_mask2
    // Reset
    if ( !reset )
      LDOS_mask_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK2)
      LDOS_mask_SYSPOR_DBB_RST_N_MASK2 <= wdata[6];
    // HW:read-write
    else
      LDOS_mask_SYSPOR_DBB_RST_N_MASK2 <= LDOS_mask_SYSPOR_DBB_RST_N_MASK2_ip;
  end

  //------------------------------------------------------------
  //   Field: EXTBST1_mask                            
  //   Width: 1              , Offset: 5              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask2_reg_extbst1_mask_syspor_dbb_rst_n_mask2
    // Reset
    if ( !reset )
      EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK2)
      EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2 <= wdata[5];
    // HW:read-write
    else
      EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2 <= EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2_ip;
  end

  //------------------------------------------------------------
  //   Field: spare                                   
  //   Width: 1              , Offset: 4              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask2_reg_spare_syspor_dbb_rst_n_mask2
    // Reset
    if ( !reset )
      spare_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK2)
      spare_SYSPOR_DBB_RST_N_MASK2 <= wdata[4];
    // HW:read-write
    else
      spare_SYSPOR_DBB_RST_N_MASK2 <= spare_SYSPOR_DBB_RST_N_MASK2_ip;
  end

  //------------------------------------------------------------
  //   Field: BUCK2_mask                              
  //   Width: 1              , Offset: 3              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask2_reg_buck2_mask_syspor_dbb_rst_n_mask2
    // Reset
    if ( !reset )
      BUCK2_mask_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK2)
      BUCK2_mask_SYSPOR_DBB_RST_N_MASK2 <= wdata[3];
    // HW:read-write
    else
      BUCK2_mask_SYSPOR_DBB_RST_N_MASK2 <= BUCK2_mask_SYSPOR_DBB_RST_N_MASK2_ip;
  end

  //------------------------------------------------------------
  //   Field: BUCK4_mask                              
  //   Width: 1              , Offset: 2              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask2_reg_buck4_mask_syspor_dbb_rst_n_mask2
    // Reset
    if ( !reset )
      BUCK4_mask_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK2)
      BUCK4_mask_SYSPOR_DBB_RST_N_MASK2 <= wdata[2];
    // HW:read-write
    else
      BUCK4_mask_SYSPOR_DBB_RST_N_MASK2 <= BUCK4_mask_SYSPOR_DBB_RST_N_MASK2_ip;
  end

  //------------------------------------------------------------
  //   Field: BUCK1_mask                              
  //   Width: 1              , Offset: 1              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask2_reg_buck1_mask_syspor_dbb_rst_n_mask2
    // Reset
    if ( !reset )
      BUCK1_mask_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK2)
      BUCK1_mask_SYSPOR_DBB_RST_N_MASK2 <= wdata[1];
    // HW:read-write
    else
      BUCK1_mask_SYSPOR_DBB_RST_N_MASK2 <= BUCK1_mask_SYSPOR_DBB_RST_N_MASK2_ip;
  end

  //------------------------------------------------------------
  //   Field: LDOP_mask                               
  //   Width: 1              , Offset: 0              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask2_reg_ldop_mask_syspor_dbb_rst_n_mask2
    // Reset
    if ( !reset )
      LDOP_mask_SYSPOR_DBB_RST_N_MASK2 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK2)
      LDOP_mask_SYSPOR_DBB_RST_N_MASK2 <= wdata[0];
    // HW:read-write
    else
      LDOP_mask_SYSPOR_DBB_RST_N_MASK2 <= LDOP_mask_SYSPOR_DBB_RST_N_MASK2_ip;
  end


  //------------------------------------------------------------
  // Register: SYSPOR_DBB_RST_N_MASK3_REG
  //   SW Access     : read-write
  //   Address Offset: 0x2
  //   HW Access     : read-write
  // 
  // Instance: SYSPOR_DBB_RST_N_MASK3
  //   Address Offset: 0x02
  //   Reset Value   : 
  // 
  // Fields:
  //     7  BUCK5_mask (SW:read-write, HW:read-write)
  //   6:0  spare (SW:read-write, HW:read-write)

  //------------------------------------------------------------
  //   Field: BUCK5_mask                              
  //   Width: 1              , Offset: 7              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask3_reg_buck5_mask_syspor_dbb_rst_n_mask3
    // Reset
    if ( !reset )
      BUCK5_mask_SYSPOR_DBB_RST_N_MASK3 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK3)
      BUCK5_mask_SYSPOR_DBB_RST_N_MASK3 <= wdata[7];
    // HW:read-write
    else
      BUCK5_mask_SYSPOR_DBB_RST_N_MASK3 <= BUCK5_mask_SYSPOR_DBB_RST_N_MASK3_ip;
  end

  //------------------------------------------------------------
  //   Field: spare                                   
  //   Width: 7              , Offset: 0              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask3_reg_spare_syspor_dbb_rst_n_mask3
    // Reset
    if ( !reset )
      spare_SYSPOR_DBB_RST_N_MASK3 <= 7'h00;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK3)
      spare_SYSPOR_DBB_RST_N_MASK3 <= wdata[6:0];
    // HW:read-write
    else
      spare_SYSPOR_DBB_RST_N_MASK3 <= spare_SYSPOR_DBB_RST_N_MASK3_ip;
  end


  //------------------------------------------------------------
  // Register: SYSPOR_DBB_RST_N_MASK4_REG
  //   SW Access     : read-write
  //   Address Offset: 0x3
  //   HW Access     : read-write
  // 
  // Instance: SYSPOR_DBB_RST_N_MASK4
  //   Address Offset: 0x03
  //   Reset Value   : 
  // 
  // Fields:
  //   7:1  spare (SW:read-write, HW:read-write)
  //     0  rtcclk12_mask (SW:read-write, HW:read-write)

  //------------------------------------------------------------
  //   Field: spare                                   
  //   Width: 7              , Offset: 1              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask4_reg_spare_syspor_dbb_rst_n_mask4
    // Reset
    if ( !reset )
      spare_SYSPOR_DBB_RST_N_MASK4 <= 7'h00;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK4)
      spare_SYSPOR_DBB_RST_N_MASK4 <= wdata[7:1];
    // HW:read-write
    else
      spare_SYSPOR_DBB_RST_N_MASK4 <= spare_SYSPOR_DBB_RST_N_MASK4_ip;
  end

  //------------------------------------------------------------
  //   Field: rtcclk12_mask                           
  //   Width: 1              , Offset: 0              
  //   SW Access: read-write , HW Access: read-write  
  //------------------------------------------------------------
  always @ (posedge clock or negedge reset)
  begin : reg_syspor_dbb_rst_n_mask4_reg_rtcclk12_mask_syspor_dbb_rst_n_mask4
    // Reset
    if ( !reset )
      rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4 <= 1'b0;
    // SW:read-write
    else if (wen_SYSPOR_DBB_RST_N_MASK4)
      rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4 <= wdata[0];
    // HW:read-write
    else
      rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4 <= rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4_ip;
  end


  //----------------------------------------------------------------------
  //                    READ BUS MULTIPLEXER
  //----------------------------------------------------------------------
  assign rmux_SYSPOR_DBB_RST_N_MASK1[7] = LDOA_mask_SYSPOR_DBB_RST_N_MASK1;
  assign rmux_SYSPOR_DBB_RST_N_MASK1[6] = LDOB_mask_SYSPOR_DBB_RST_N_MASK1;
  assign rmux_SYSPOR_DBB_RST_N_MASK1[5] = LDOC_mask_SYSPOR_DBB_RST_N_MASK1;
  assign rmux_SYSPOR_DBB_RST_N_MASK1[4] = LDOF_mask_SYSPOR_DBB_RST_N_MASK1;
  assign rmux_SYSPOR_DBB_RST_N_MASK1[3] = LDOG_mask_SYSPOR_DBB_RST_N_MASK1;
  assign rmux_SYSPOR_DBB_RST_N_MASK1[2] = LDOH_mask_SYSPOR_DBB_RST_N_MASK1;
  assign rmux_SYSPOR_DBB_RST_N_MASK1[1] = spare_SYSPOR_DBB_RST_N_MASK1;
  assign rmux_SYSPOR_DBB_RST_N_MASK1[0] = LDOT_mask_SYSPOR_DBB_RST_N_MASK1;

  assign rmux_SYSPOR_DBB_RST_N_MASK2[7] = LDOM_mask_SYSPOR_DBB_RST_N_MASK2;
  assign rmux_SYSPOR_DBB_RST_N_MASK2[6] = LDOS_mask_SYSPOR_DBB_RST_N_MASK2;
  assign rmux_SYSPOR_DBB_RST_N_MASK2[5] = EXTBST1_mask_SYSPOR_DBB_RST_N_MASK2;
  assign rmux_SYSPOR_DBB_RST_N_MASK2[4] = spare_SYSPOR_DBB_RST_N_MASK2;
  assign rmux_SYSPOR_DBB_RST_N_MASK2[3] = BUCK2_mask_SYSPOR_DBB_RST_N_MASK2;
  assign rmux_SYSPOR_DBB_RST_N_MASK2[2] = BUCK4_mask_SYSPOR_DBB_RST_N_MASK2;
  assign rmux_SYSPOR_DBB_RST_N_MASK2[1] = BUCK1_mask_SYSPOR_DBB_RST_N_MASK2;
  assign rmux_SYSPOR_DBB_RST_N_MASK2[0] = LDOP_mask_SYSPOR_DBB_RST_N_MASK2;

  assign rmux_SYSPOR_DBB_RST_N_MASK3[7] = BUCK5_mask_SYSPOR_DBB_RST_N_MASK3;
  assign rmux_SYSPOR_DBB_RST_N_MASK3[6:0] = spare_SYSPOR_DBB_RST_N_MASK3;

  assign rmux_SYSPOR_DBB_RST_N_MASK4[7:1] = spare_SYSPOR_DBB_RST_N_MASK4;
  assign rmux_SYSPOR_DBB_RST_N_MASK4[0] = rtcclk12_mask_SYSPOR_DBB_RST_N_MASK4;

  always @ ( * )
  begin : read_bus_mux
    // PUT REGISTER VALUE ON READ DATA BUS
    rack = 1'b0;
    raddrerr = 1'b0;
    if (rstrobe )
    begin
      case (raddr )
        SYSPOR_DBB_RST_N_MASK1_ADDR:
        begin
          rdata = rmux_SYSPOR_DBB_RST_N_MASK1;
        end
        SYSPOR_DBB_RST_N_MASK2_ADDR:
        begin
          rdata = rmux_SYSPOR_DBB_RST_N_MASK2;
        end
        SYSPOR_DBB_RST_N_MASK3_ADDR:
        begin
          rdata = rmux_SYSPOR_DBB_RST_N_MASK3;
        end
        SYSPOR_DBB_RST_N_MASK4_ADDR:
        begin
          rdata = rmux_SYSPOR_DBB_RST_N_MASK4;
        end
        default:
        begin
          rdata =  DEF_RDATA_VAL;
          raddrerr =  1'b1;
        end
      endcase
      rack = 1'b1;
    end
    else
      begin
        rdata =  DEF_RDATA_VAL;
      end
  end
endmodule

