-- ************************************************************************
--               Copyright 2006-2015 Mentor Graphics Corporation
--                            All Rights Reserved.
--  
--               THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
--             INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS 
--            CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
--                                   TERMS.
--  
-- ************************************************************************
--  
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - Top module
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/15/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;

use work.components.all;

entity axi4lite_to_apb4 is 
generic (
AW : integer := 32;
DW : integer := 32 
);
port (
-- APB4 Master Interface Signals
PCLK_i        : in  std_logic;
PRESETn_i     : in  std_logic;
PSELx_o       : out std_logic;
PADDR_o       : out std_logic_vector(31 downto 0);
PENABLE_o     : out std_logic;
PWRITE_o      : out std_logic;
PPROT_o       : out std_logic_vector(2 downto 0);
PWDATA_o      : out std_logic_vector(DW-1 downto 0);
PSTRB_o       : out std_logic_vector((DW/8)-1 downto 0);
PREADY_i      : in  std_logic;
PRDATA_i      : in  std_logic_vector(DW-1 downto 0);
PSLVERR_i     : in  std_logic;


-- APB2 Interface Signals (Mem Reg)
PSELx_i_csr   : in  std_logic;
PCLK_i_csr    : in  std_logic;
PRESETn_i_csr : in  std_logic;
PENABLE_i_csr : in  std_logic;
PADDR_i_csr   : in  std_logic_vector(31 downto 0);
PWRITE_i_csr  : in  std_logic;
PWDATA_i_csr  : in  std_logic_vector(31 downto 0);
PRDATA_o_csr  : out std_logic_vector(31 downto 0);


-- AXI4Lite Slave Signals
ACLK_i        : in  std_logic;
ARESETn_i     : in  std_logic;
-- WA Channel
AWADDR_i      : in  std_logic_vector(AW-1 downto 0);
AWPROT_i      : in  std_logic_vector(2 downto 0);
AWVALID_i     : in  std_logic;
AWREADY_o     : out std_logic;
-- WD Channel
WDATA_i       : in  std_logic_vector(DW-1 downto 0);
WSTRB_i       : in  std_logic_vector((DW/8)-1 downto 0);
WVALID_i      : in  std_logic;
WREADY_o      : out std_logic;
-- WR Channel
BRESP_o       : out std_logic_vector(1 downto 0);
BVALID_o      : out std_logic;
BREADY_i      : in  std_logic;
-- RA Channel
ARADDR_i      : in  std_logic_vector(AW-1 downto 0);
ARPROT_i      : in  std_logic_vector(2 downto 0);
ARVALID_i     : in  std_logic;
ARREADY_o     : out std_logic;
-- RD Channel
RDATA_o       : out std_logic_vector(DW-1 downto 0);
RRESP_o       : out std_logic_vector(1 downto 0);
RVALID_o      : out std_logic;
RREADY_i      : in  std_logic;

-- Misc. signals
use_1clk_i    : in  std_logic
);
end entity;

architecture rtl of axi4lite_to_apb4 is

-- signal definitions
signal waddr_prot_wdata   : std_logic_vector(AW+2 downto 0);
signal waddr_prot_rdata   : std_logic_vector(AW+2 downto 0);
signal waddr_wen_push     : std_logic;
signal waddr_wen_pop      : std_logic;
signal waddr_fifo_full    : std_logic;
signal waddr_fifo_empty   : std_logic;
signal data_strb_wdata    : std_logic_vector((DW/8)+DW-1 downto 0);
signal data_strb_rdata    : std_logic_vector((DW/8)+DW-1 downto 0);
signal data_wen_push      : std_logic;
signal data_wen_pop       : std_logic;
signal data_fifo_full     : std_logic;
signal data_fifo_empty    : std_logic;
signal raddr_prot_wdata   : std_logic_vector(AW+2 downto 0);
signal raddr_prot_rdata   : std_logic_vector(AW+2 downto 0);
signal raddr_wen_push     : std_logic;
signal raddr_wen_pop      : std_logic;
signal raddr_fifo_full    : std_logic;
signal raddr_fifo_empty   : std_logic;
signal rdata_wen_push     : std_logic;
signal rdata_wen_pop      : std_logic;
signal rdata_wdata        : std_logic_vector(DW downto 0);
signal rdata_rdata        : std_logic_vector(DW downto 0);
signal rdata_fifo_empty   : std_logic;
signal rdata_fifo_full    : std_logic;
signal rdata_mstr_2_axi   : std_logic_vector(DW-1 downto 0);
signal rd_resp_mstr_2_axi : std_logic;
signal rd_vld_mstr_2_axi  : std_logic;
signal wr_resp_mstr_2_axi : std_logic;
signal rd_mstr_2_axi      : std_logic;
signal wr_mstr_2_axi      : std_logic;
signal ratio              : std_logic_vector(2 downto 0);
signal w_use_merr_resp    : std_logic;
signal wa_ready_sc        : std_logic;
signal wd_ready_sc        : std_logic;
signal ra_ready_sc        : std_logic;
signal rd_data_slverr_sc  : std_logic_vector(DW downto 0);
signal rd_ready_sc        : std_logic;
signal rd_valid_sc        : std_logic;
signal b_ready_sc         : std_logic;
signal b_valid_sc         : std_logic;
signal b_resp_sc          : std_logic;

begin

-- instantiations

u_master_interface: master_interface 
generic map (AW => AW, DW => DW)
port map (
-- APB4 Master Interface Signals
PSELx          => PSELx_o,
PCLK           => PCLK_i,
PRESETn        => PRESETn_i,
PADDR          => PADDR_o,
PENABLE        => PENABLE_o,
PWRITE         => PWRITE_o,
PPROT          => PPROT_o,
PWDATA         => PWDATA_o,
PSTRB          => PSTRB_o,
PREADY         => PREADY_i,
PRDATA         => PRDATA_i,
PSLVERR        => PSLVERR_i,

-- internal signals
use_1clk       => use_1clk_i,
wr_rd_ratio    => ratio,
wa_fifo_rdata  => waddr_prot_rdata,
wa_fifo_pop    => waddr_wen_pop,
wa_fifo_empty  => waddr_fifo_empty,
wd_fifo_rdata  => data_strb_rdata,
wd_fifo_pop    => data_wen_pop,
wd_fifo_empty  => data_fifo_empty,
ra_fifo_rdata  => raddr_prot_rdata,
ra_fifo_pop    => raddr_wen_pop,
ra_fifo_empty  => raddr_fifo_empty,
rd_fifo_wdata  => rdata_wdata,
rd_fifo_push   => rdata_wen_push,
rd_fifo_full   => rdata_fifo_full,
wr_resp_2_axi  => wr_resp_mstr_2_axi,
wr_2_axi       => wr_mstr_2_axi,
rd_2_axi       => rd_mstr_2_axi,
wa_addr_prot   => waddr_prot_wdata,
wa_wen         => waddr_wen_push,
wa_ready       => wa_ready_sc,
wd_data_strb   => data_strb_wdata,
wd_wen         => data_wen_push,
wd_ready       => wd_ready_sc,
ra_addr_prot   => raddr_prot_wdata,
ra_wen         => raddr_wen_push,
ra_ready       => ra_ready_sc,
rd_data_slverr => rd_data_slverr_sc,
rd_ready       => rd_ready_sc,
rd_valid       => rd_valid_sc,
b_ready        => b_ready_sc,
b_valid        => b_valid_sc,
b_resp         => b_resp_sc
);


u_csr_interface_apb: csr_interface_apb
generic map (AW => AW, DW =>DW)
port map (
-- APB2 Interface Signals
PSELx         => PSELx_i_csr,
PCLK          => PCLK_i_csr,
PRESETn       => PRESETn_i_csr,
PENABLE       => PENABLE_i_csr,
PADDR         => PADDR_i_csr,
PWRITE        => PWRITE_i_csr,
PWDATA        => PWDATA_i_csr,
PRDATA        => PRDATA_o_csr,
-- internal signals
axi_rd        => raddr_wen_push,
axi_wr        => waddr_wen_push,
mstr_rd       => rd_mstr_2_axi,
mstr_wr       => wr_mstr_2_axi,
wr_rd_ratio   => ratio,
use_merr_resp => w_use_merr_resp,
wa            => waddr_prot_rdata,
wa_vld        => waddr_wen_pop,
wd            => data_strb_rdata(31 downto 0),
wd_vld        => data_wen_pop,
ra            => raddr_prot_rdata,
ra_vld        => raddr_wen_pop,
rd            => rdata_wdata(31 downto 0),
rd_vld        => rdata_wen_push,
mclk          => PCLK_i,
mrstn         => PRESETn_i
);


u_axi4lite_slave: axi4lite_slave
generic map (AW => AW, DW => DW)
port map (
-- AXI4 Master Signals
ACLK           => ACLK_i,
ARESETn        => ARESETn_i,
-- WA Channel
AWADDR         => AWADDR_i,
AWPROT         => AWPROT_i,  -- will set to 000
AWVALID        => AWVALID_i,
AWREADY        => AWREADY_o,
-- WD Channel
WDATA          => WDATA_i,
WSTRB          => WSTRB_i,  -- will set to 1111
WVALID         => WVALID_i,
WREADY         => WREADY_o,
-- WR Channel
BRESP          => BRESP_o,
BVALID         => BVALID_o,
BREADY         => BREADY_i,
-- RA Channel
ARADDR         => ARADDR_i,
ARPROT         => ARPROT_i, 
ARVALID        => ARVALID_i,
ARREADY        => ARREADY_o,
-- RD Channel
RDATA          => RDATA_o,
RRESP          => RRESP_o,
RVALID         => RVALID_o,
RREADY         => RREADY_i,

-- internal signals
use_1clk       => use_1clk_i,
w_addr_prot    => waddr_prot_wdata,
w_addr_wen     => waddr_wen_push,
w_addr_full    => waddr_fifo_full,
w_data_strb    => data_strb_wdata,
w_data_wen     => data_wen_push,
w_data_full    => data_fifo_full,
r_addr_prot    => raddr_prot_wdata,
r_addr_wen     => raddr_wen_push,
r_addr_full    => raddr_fifo_full,
r_data_err     => rdata_rdata,
r_data_ren     => rdata_wen_pop,
r_data_empty   => rdata_fifo_empty,
wr_resp_2_axi  => wr_resp_mstr_2_axi,
mstr_wr_2_axi  => wr_mstr_2_axi,
use_mwerr_resp => w_use_merr_resp,
wa_ready       => wa_ready_sc,
wd_ready       => wd_ready_sc,
ra_ready       => ra_ready_sc,
rd_data_slverr => rd_data_slverr_sc,
rd_ready       => rd_ready_sc,
rd_valid       => rd_valid_sc,
b_ready        => b_ready_sc,
b_valid        => b_valid_sc,
b_resp         => b_resp_sc
);


u_fifos: fifos
generic map (DW => DW)
port map (
s_rstn   => ARESETn_i,
s_clk    => ACLK_i,
m_rstn   => PRESETn_i,
m_clk    => PCLK_i,
wa_push  => waddr_wen_push,
wa_pop   => waddr_wen_pop,
wa_wdata => waddr_prot_wdata,
wa_rdata => waddr_prot_rdata,
wa_empty => waddr_fifo_empty,
wa_full  => waddr_fifo_full,
wd_push  => data_wen_push,
wd_pop   => data_wen_pop,
wd_wdata => data_strb_wdata,
wd_rdata => data_strb_rdata,
wd_empty => data_fifo_empty,
wd_full  => data_fifo_full,
ra_push  => raddr_wen_push,
ra_pop   => raddr_wen_pop,
ra_wdata => raddr_prot_wdata,
ra_rdata => raddr_prot_rdata,
ra_empty => raddr_fifo_empty,
ra_full  => raddr_fifo_full,
rd_push  => rdata_wen_push,
rd_pop   => rdata_wen_pop,
rd_wdata => rdata_wdata,
rd_rdata => rdata_rdata,
rd_empty => rdata_fifo_empty,
rd_full  => rdata_fifo_full
);

end rtl;
