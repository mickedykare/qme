// ************************************************************************
//               Copyright 2006-2015 Mentor Graphics Corporation
//                            All Rights Reserved.
//  
//               THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
//             INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS 
//            CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
//                                   TERMS.
//  
// ************************************************************************
//  
// DESCRIPTION   : AXI4Lite to APB4 Bridge - Config/Status Registers
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/16/15
// 
// ************************************************************************

module config_status_reg (
// Interface Signals
input             rstn, 
input             clk, 
input             wen,
input  [31:0]     waddr,
input  [31:0]     wdata,
input             ren,
input  [31:0]     raddr,
output [31:0]     rdata,

// Internal Signals
input             axi_rd,
input             axi_wr,
input             mstr_rd,
input             mstr_wr,
output  [2:0]  mst_config_wr_rd_ratio,
output         slv_config_use_merr_resp,
input [31:0]      sample_data,
input             sample_reg_wr,
output            sample_reg_rd,
output reg [15:0] sample_conf_ctrl
);

// Internal definitions
//wire [31:0] axi_cnt_status;
wire axi_cnt_status_rd;
wire mst_cnt_status_rd;
wire slv_conf_rd, slv_conf_wr;
wire mst_conf_rd, mst_conf_wr;
wire sample_conf_rd, sample_conf_wr;
wire axi_rd_sync;
wire axi_wr_sync;
wire mstr_rd_sync;
wire mstr_wr_sync;

// define rdata buses from registers
   wire [31:0] rdata_apb_stat,
	       rdata_axi_stat,
	       rdata_slave_config,
	       rdata_master_config,
	       rdata_sample_config,
	       rdata_sample;
   
   
// Configuration and Status Registers

// base address for APB access: 32'hC0F16000

// Name: axi_stat
// Description: Slave RD/WR Status
// Address space is: C0F16000 with offset x000
// inital value if 0
// read to clear
// bits [9:0]   wr_cnt
// bits [19:10] rd_cnt
// bits [31:20] unused

   assign axi_cnt_status_rd = (ren && (raddr == 32'hC0F16000));

   axi_stat_reg axi_stat(.clk(clk),
			 .rstn(rstn),
			 .read(axi_cnt_status_rd),
			 .axi_rd_sync(axi_rd_sync),
			 .axi_wr_sync(axi_wr_sync),
			 .rdata(rdata_axi_stat));
// Name: apb_stat
// Description: Master RD/WR Count Status
// Address space is: C0F16000 with offset x004
// inital value if 0
// Read to Clear
// bits [9:0]   wr_cnt
// bits [19:10] rd_cnt
// bits [31:20] unused

assign mst_cnt_status_rd = (ren && (raddr == 32'hC0F16004));

   apb_stat_reg apb_stat(.clk(clk),
			 .rstn(rstn),
			 .read(axi_cnt_status_rd),
			 .mstr_rd_sync(mstr_rd_sync),
			 .mstr_wr_sync(mstr_wr_sync),
			 .rdata(rdata_apb_stat));

   
// Name: slv_config
// Description: Slave Config  Register
// Address space is: C0F16000 with offset x010
// inital value if 0
// Read/Write
// bits [0]    use_merr_resp 
// bits [31:1] unused

   assign slv_conf_rd = (ren && (raddr == 32'hC0F16010));
   assign slv_conf_wr = (wen && (waddr == 32'hC0F16010));
   
   slave_config_reg slave_config(.clk(clk),
				 .rstn(rstn),
				 .write(slv_conf_wr),
				 .wdata(wdata),
				 .rdata(rdata_slave_config),
				 .slv_config_use_merr_resp(slv_config_use_merr_resp));


// Name: mst_config
// Description: Master Config Register
// Address space is: C0F16000 with offset x020
// inital value if 0
// Read/Write
// bits [2:0]   wr_rd_ratio 
// bits [31:20] unused

   assign mst_conf_rd = (ren && (raddr == 32'hC0F16020));
   assign mst_conf_wr = (wen && (waddr == 32'hC0F16020));

   master_config_reg master_config(.clk(clk),
				   .rstn(rstn),
				   .write(mst_conf_wr),
				   .wdata(wdata),
				   .rdata(rdata_master_config),
				   .mst_config_wr_rd_ratio(mst_config_wr_rd_ratio));

// Name: sample_conf
// Description: Sample Config Register 
// Address space is: C0F16000 with offset xB60
// inital value if 0
// Read/Write
// bits [31:16]   ctrl 
// 31  sample waddr normal data
// 30  sample waddr normal instr
// 29  sample waddr privileged data
// 28  sample waddr privileged instr
// 27  sample wdata normal data
// 26  sample wdata normal instr
// 25  sample wdata privileged data
// 24  sample wdata privileged instr
// 23  sample raddr normal data
// 22  sample raddr normal instr
// 21  sample raddr privileged data
// 20  sample raddr privileged instr
// 19  sample rdata normal data
// 18  sample rdata normal instr
// 17  sample rdata privileged data
// 16  sample rdata privileged instr

assign sample_conf_rd = (ren && (raddr == 32'hC0F16B60));
assign sample_conf_wr = (wen && (waddr == 32'hC0F16B60));

   sample_config_reg sample_config(.clk(clk),
				   .rstn(rstn),
				   .write(sample_conf_wr),
				   .wdata(wdata),
				   .rdata(rdata_sample_config),
				   .sample_conf_ctrl(sample_conf_ctrl)			 
			 );

// Name: sample 
// Description: Register of samples transactions
// Address space is: C0F16000 with offset xBAC
// inital value if 0
// Read Only
// bits [31:0] reg 

   assign sample_reg_rd = (ren && (raddr == 32'hC0F16BAC));
   
   sample_reg sample(.clk(clk),
		     .rstn(rstn),
		     .read(sample_reg_rd),
		     .rdata(rdata_sample),
		     .sample_data(sample_data));

// Check that only one read enable is high at the time
   property p_check_read_enables(array);
      @(posedge clk) disable iff(~rstn)
	($countones(array) <= 1);
   endproperty
   
   a_check_read_enables:assert 
     property(p_check_read_enables({axi_cnt_status_rd,mst_cnt_status_rd,slv_conf_rd,mst_conf_rd,sample_conf_rd,sample_reg_rd}));

   
// output mux
   assign rdata = ren               ? 
		  axi_cnt_status_rd ? rdata_axi_stat :
		  mst_cnt_status_rd ? rdata_apb_stat :
		  slv_conf_rd       ? rdata_slave_config  :
		  mst_conf_rd       ? rdata_master_config  :
		  sample_conf_rd    ? rdata_sample_config  :
		  sample_reg_rd     ? rdata_sample: 32'h00000000
		  :  32'h00000000 ;


// syncronizers
pulse_sync u_axi_rd_sync (
.rstn(rstn),
.clk(clk),
.d(axi_rd),
.p(axi_rd_sync)
);

pulse_sync u_axi_wr_sync (
.rstn(rstn),
.clk(clk),
.d(axi_wr),
.p(axi_wr_sync)
);

pulse_sync u_axi_mstr_sync (
.rstn(rstn),
.clk(clk),
.d(mstr_rd),
.p(mstr_rd_sync)
);

pulse_sync u_mstr_wr_sync (
.rstn(rstn),
.clk(clk),
.d(mstr_wr),
.p(mstr_wr_sync)
);


endmodule
