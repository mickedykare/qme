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
// DESCRIPTION   : AXI4Lite to APB4 Bridge - CSR Interface (APB)
// AUTHOR        : Mark Eslinger 
// Last Modified : 1/16/15
// 
// ************************************************************************

module csr_interface_apb #(
parameter AW  = 32,
parameter DW  = 32 
)
(
// APB Interface Signals
  input           PSELx,
  input           PCLK,
  input           PRESETn,
  input           PENABLE,
  input  [31:0]   PADDR,
  input           PWRITE,
  input  [31:0]   PWDATA,
  output [31:0]   PRDATA,

// internal signals
  input           axi_rd,
  input           axi_wr,
  input           mstr_rd,
  input           mstr_wr,
  output [2:0]    wr_rd_ratio,
  output          use_merr_resp,
  input  [AW+2:0] wa,
  input           wa_vld,
  input  [DW-1:0] wd,
  input           wd_vld,
  input  [AW+2:0] ra,
  input           ra_vld,
  input  [DW-1:0] rd,
  input           rd_vld,
  input           mclk,
  input           mrstn
);


// signal definitions
`include "defines.h"
samp_st        cstate, nstate;
wire           w_en;
wire           r_en;
wire [31:0]    w_addr; 
wire [31:0]    w_data; 
wire [31:0]    r_addr; 
wire [31:0]    r_data;
wire [31:0]    sample_dat;
wire           sample_reg_ld;
wire           sample_reg_rd;
wire [15:0]    sample_cmd;
wire           sf_fe, sf_ff;
wire           sf_push, sf_pop;
reg  [31:0]    sf_wdata; 
wire           push_wa_n_d;
wire           push_wa_n_i;
wire           push_wa_p_d;
wire           push_wa_p_i;
wire           push_wa;
wire           push_wd_n_d;
wire           push_wd_n_i;
wire           push_wd_p_d;
wire           push_wd_p_i;
wire           push_wd;
wire           push_ra_n_d;
wire           push_ra_n_i;
wire           push_ra_p_d;
wire           push_ra_p_i;
wire           push_ra;
wire           push_rd_n_d;
wire           push_rd_n_i;
wire           push_rd_p_d;
wire           push_rd_p_i;
wire           push_rd;
reg [2:0]      ra_d;


// instantiations
//
apb_slave_int u_apb_slave_int (
// APB2 Interface Signals
.PSELx(PSELx),
.PCLK(PCLK),
.PRESETn(PRESETn),
.PENABLE(PENABLE),
.PADDR(PADDR),
.PWRITE(PWRITE),
.PWDATA(PWDATA),
.PRDATA(PRDATA),
.wen(w_en),
.waddr(w_addr),
.wdata(w_data),
.ren(r_en),
.raddr(r_addr),
.rdata(r_data)
);


config_status_reg u_config_status_reg (
// Interface Signals
.rstn(PRESETn),
.clk(PCLK),
.wen(w_en),
.waddr(w_addr),
.wdata(w_data),
.ren(r_en),
.raddr(r_addr),
.rdata(r_data),

// Internal Signals
.axi_rd(axi_rd),
.axi_wr(axi_wr),
.mstr_rd(mstr_rd),
.mstr_wr(mstr_wr),
.mst_config_wr_rd_ratio(wr_rd_ratio),
.slv_config_use_merr_resp(use_merr_resp),
.sample_data(sample_dat),
.sample_reg_wr(sample_reg_ld),
.sample_reg_rd(sample_reg_rd),
.sample_conf_ctrl(sample_cmd)
);

// sample cmd
// 15  sample waddr normal data
// 14  sample waddr normal instr
// 13  sample waddr privileged data
// 12  sample waddr privileged instr
// 11  sample wdata normal data
// 10  sample wdata normal instr
// 09  sample wdata privileged data
// 08  sample wdata privileged instr
// 07  sample raddr normal data
// 06  sample raddr normal instr
// 05  sample raddr privileged data
// 04  sample raddr privileged instr
// 03  sample rdata normal data
// 02  sample rdata normal instr
// 01  sample rdata privileged data
// 00  sample rdata privileged instr
assign push_wa_n_d = sample_cmd[15] & wa_vld & (wa[34:32] == 3'b010);
assign push_wa_n_i = sample_cmd[14] & wa_vld & (wa[34:32] == 3'b011);
assign push_wa_p_d = sample_cmd[13] & wa_vld & (wa[34:32] == 3'b110);
assign push_wa_p_i = sample_cmd[12] & wa_vld & (wa[34:32] == 3'b111);
assign push_wa     = push_wa_n_d | push_wa_n_i | push_wa_p_d | push_wa_p_i;

assign push_wd_n_d = sample_cmd[11] & wd_vld & (wa[34:32] == 3'b010);
assign push_wd_n_i = sample_cmd[10] & wd_vld & (wa[34:32] == 3'b011);
assign push_wd_p_d = sample_cmd[9]  & wd_vld & (wa[34:32] == 3'b110);
assign push_wd_p_i = sample_cmd[8]  & wd_vld & (wa[34:32] == 3'b111);
assign push_wd     = push_wd_n_d | push_wd_n_i | push_wd_p_d | push_wd_p_i;

assign push_ra_n_d = sample_cmd[7]  & ra_vld & (ra[34:32] == 3'b010);
assign push_ra_n_i = sample_cmd[6]  & ra_vld & (ra[34:32] == 3'b011);
assign push_ra_p_d = sample_cmd[5]  & ra_vld & (ra[34:32] == 3'b110);
assign push_ra_p_i = sample_cmd[4]  & ra_vld & (ra[34:32] == 3'b111);
assign push_ra     = push_ra_n_d | push_ra_n_i | push_ra_p_d | push_ra_p_i;

always @(posedge mclk or negedge mrstn)
if (!mrstn)
	ra_d <= 3'b0;
else
	if (ra_vld)
		ra_d <= ra[34:32];
	else
		ra_d <= ra_d;

assign push_rd_n_d = sample_cmd[3]  & rd_vld & (ra_d == 3'b010);
assign push_rd_n_i = sample_cmd[2]  & rd_vld & (ra_d == 3'b011);
assign push_rd_p_d = sample_cmd[1]  & rd_vld & (ra_d == 3'b110);
assign push_rd_p_i = sample_cmd[0]  & rd_vld & (ra_d == 3'b111);
assign push_rd     = push_rd_n_d | push_rd_n_i | push_rd_p_d | push_rd_p_i;

assign sf_push     = !sf_ff & (push_wa | push_wd | push_ra | push_rd);

always @* 
case ({push_wa,push_wd,push_ra,push_rd})
4'b0000: sf_wdata <= 32'b00000000;
4'b0001: sf_wdata <= rd;
4'b0010: sf_wdata <= ra[31:0];
4'b0100: sf_wdata <= wd;
4'b1000: sf_wdata <= wa[31:0];
4'b1100: sf_wdata <= wd;           // data takes precedence over addr 
default: sf_wdata <= 32'b00000000;
endcase

// once fifo is full won't be written to. pull data when available or read
dp_fifo #(.AW(2), .DW(DW)) u_samplefifo (
.wrstn(mrstn),
.wclk(mclk),
.rrstn(PRESETn),
.rclk(PCLK),
.push(sf_push),
.pop(sf_pop),
.wdata(sf_wdata),
.rdata(sample_dat),
.empty(sf_fe),
.full(sf_ff)
);



always @(posedge PCLK or negedge PRESETn)
if (!PRESETn)
	cstate <= INIT;
else
	cstate <= nstate;


always @*
case (cstate)
INIT: if (!sf_fe)
		nstate <= POP;
	else
		nstate <= INIT;
POP: nstate <= LOAD;
LOAD: nstate <= HOLD;
HOLD: if (sf_fe)
		nstate <= INIT;
	else if (sample_reg_rd)
		nstate <= POP;
	else
		nstate <= HOLD;
default: nstate <= INIT;
endcase

assign sf_pop        = (cstate == POP);
assign sample_reg_ld = (cstate == LOAD);

endmodule
