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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - Components Package 
-- AUTHOR        : Mark Eslinger
-- Last Modified : 1/16/15
--
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;


package components is

component MUX2to1_bit is
port (
di0  : in  std_logic;
di1  : in  std_logic;
sel  : in  std_logic;
dout : out std_logic
);
end component;

component MUX2to1_bus is
generic (DWIDTH : integer := 1);
port (
di0  : in  std_logic_vector(DWIDTH-1 downto 0);
di1  : in  std_logic_vector(DWIDTH-1 downto 0);
sel  : in  std_logic;
dout : out std_logic_vector(DWIDTH-1 downto 0)
);
end component;

component DEC1to2_bit is
port (
di  : in  std_logic;
sel : in  std_logic;
do0 : out std_logic;
do1 : out std_logic
);
end component;

component DEC1to2_bus is
generic (DWIDTH : integer := 1);
port (
di  : in  std_logic_vector(DWIDTH-1 downto 0);
sel : in  std_logic;
do0 : out std_logic_vector(DWIDTH-1 downto 0);
do1 : out std_logic_vector(DWIDTH-1 downto 0)
);
end component;

component sync_2dff is
generic (DW : integer := 1);
port (
rstn : in  std_logic;
clk  : in  std_logic;
d    : in  std_logic_vector(DW-1 downto 0);
q    : out std_logic_vector(DW-1 downto 0)
);
end component;

component pulse_sync is
port (
rstn : in  std_logic;
clk  : in  std_logic;
d    : in  std_logic;
p    : out std_logic
);
end component;

component psync_dmux is
generic (DWIDTH : integer := 1);
port (
rstn : in  std_logic;
clk  : in  std_logic;
sel  : in  std_logic;
din  : in  std_logic_vector(DWIDTH-1 downto 0);
dout : out std_logic_vector(DWIDTH-1 downto 0)
);
end component;

component dp_sram is
generic (
AW : integer := 32;
DW : integer := 32
);
port (
wclk  : in  std_logic;
rclk  : in  std_logic;
waddr : in  std_logic_vector(AW-1 downto 0);
raddr : in  std_logic_vector(AW-1 downto 0);
wdata : in  std_logic_vector(DW-1 downto 0);
rdata : out std_logic_vector(DW-1 downto 0);
wen   : in  std_logic;
ren   : in  std_logic
);
end component;

component dp_fifo is
generic (
AW : integer := 3;
DW : integer := 8
);
port (
wrstn : in  std_logic;
wclk  : in  std_logic;
rrstn : in  std_logic;
rclk  : in  std_logic;
push  : in  std_logic;
pop   : in  std_logic;
wdata : in  std_logic_vector(DW-1 downto 0);
rdata : out std_logic_vector(DW-1 downto 0);
empty : out std_logic;
full  : out std_logic
);
end component;

component fifos is
generic (
DW : integer := 32
);
port (
s_rstn   : in  std_logic;
s_clk    : in  std_logic;
m_rstn   : in  std_logic;
m_clk    : in  std_logic;
wa_push  : in  std_logic;
wa_pop   : in  std_logic;
wa_wdata : in  std_logic_vector(DW+2 downto 0);
wa_rdata : out std_logic_vector(DW+2 downto 0);
wa_empty : out std_logic;
wa_full  : out std_logic;
wd_push  : in  std_logic;
wd_pop   : in  std_logic;
wd_wdata : in  std_logic_vector((DW/8)+DW-1 downto 0);
wd_rdata : out std_logic_vector((DW/8)+DW-1 downto 0);
wd_empty : out std_logic;
wd_full  : out std_logic;
ra_push  : in  std_logic;
ra_pop   : in  std_logic;
ra_wdata : in  std_logic_vector(DW+2 downto 0);
ra_rdata : out std_logic_vector(DW+2 downto 0);
ra_empty : out std_logic;
ra_full  : out std_logic;
rd_push  : in  std_logic;
rd_pop   : in  std_logic;
rd_wdata : in  std_logic_vector(DW downto 0);
rd_rdata : out std_logic_vector(DW downto 0);
rd_empty : out std_logic;
rd_full  : out std_logic
);
end component;

component apb_access_arb is
port (
rstn     : in std_logic;
clk      : in std_logic;
ratio    : in std_logic_vector(2 downto 0);
ra_avail : in std_logic;
rd_avail : in std_logic;
wr_avail : in std_logic;
rd       : in std_logic;
wr       : in std_logic;
rd_en    : out std_logic;
wr_en    : out std_logic
);
end component;

component pinmux is
generic (
AW : integer := 32;
DW : integer := 32
);
port (
-- APB4 Master Interface Signals
PSELx      : out std_logic;
PADDR      : out std_logic_vector(31 downto 0);
PENABLE    : out std_logic;
PWRITE     : out std_logic;
PPROT      : out std_logic_vector(2 downto 0);
PWDATA     : out std_logic_vector(DW-1 downto 0);
PSTRB      : out std_logic_vector((DW/8)-1 downto 0);
PREADY     : in  std_logic;
PRDATA     : in  std_logic_vector(DW-1 downto 0);
PSLVERR    : in  std_logic;

-- Single clock signals
pselx_sc   : in  std_logic;
paddr_sc   : in  std_logic_vector(31 downto 0);
penable_sc : in  std_logic;
pwrite_sc  : in  std_logic;
pprot_sc   : in  std_logic_vector(2 downto 0);
pwdata_sc  : in  std_logic_vector(DW-1 downto 0);
pstrb_sc   : in  std_logic_vector((DW/8)-1 downto 0);
pready_sc  : out std_logic;
prdata_sc  : out std_logic_vector(DW-1 downto 0);
pslverr_sc : out std_logic;

-- Multi clock signals
pselx_mc   : in  std_logic;
paddr_mc   : in  std_logic_vector(31 downto 0);
penable_mc : in  std_logic;
pwrite_mc  : in  std_logic;
pprot_mc   : in  std_logic_vector(2 downto 0);
pwdata_mc  : in  std_logic_vector(DW-1 downto 0);
pstrb_mc   : in  std_logic_vector((DW/8)-1 downto 0);
pready_mc  : out std_logic;
prdata_mc  : out std_logic_vector(DW-1 downto 0);
pslverr_mc : out std_logic;

-- other signals
use_1clk   : in  std_logic
);
end component;

component apb_master_sc is
port (
-- APB4 Interface Signals
PCLK    : in  std_logic;
PRESETn : in  std_logic;
PSELx   : out std_logic;
PENABLE : out std_logic;
PADDR   : out std_logic_vector(31 downto 0);
PPROT   : out std_logic_vector(2 downto 0);
PWRITE  : out std_logic;
PWDATA  : out std_logic_vector(31 downto 0);
PSTRB   : out std_logic_vector(3 downto 0); -- drive low for reads
PREADY  : in  std_logic;
PRDATA  : in  std_logic_vector(31 downto 0);
PSLVERR : in  std_logic; -- can tie 0 if not used
--internal Signals
use_1clk     : in  std_logic;
waddr_prot   : in  std_logic_vector(34 downto 0);
waddr_wen    : in  std_logic;
waddr_ready  : out std_logic;
wdata_strb   : in  std_logic_vector(35 downto 0);
wdata_wen    : in  std_logic;
wdata_ready  : out std_logic;
raddr_prot   : in  std_logic_vector(34 downto 0);
raddr_wen    : in  std_logic;
raddr_ready  : out std_logic;
rdata_slverr : out std_logic_vector(32 downto 0);
rdata_ready  : in  std_logic;
rdata_valid  : out std_logic;
bready       : in  std_logic;
bvalid       : out std_logic;
bresp        : out std_logic
);
end component;

component apb_master_mc is
port (
-- APB4 Interface Signals
PCLK          : in  std_logic;
PRESETn       : in  std_logic;
PSELx         : out std_logic;
PENABLE       : out std_logic;
PADDR         : out std_logic_vector(31 downto 0);
PPROT         : out std_logic_vector(2 downto 0);
PWRITE        : out std_logic;
PWDATA        : out std_logic_vector(31 downto 0);
PSTRB         : out std_logic_vector(3 downto 0); -- drive low for reads
PREADY        : in  std_logic;
PRDATA        : in  std_logic_vector(31 downto 0);
PSLVERR       : in  std_logic; -- can tie 0 if not used
--internal Signals
use_1clk      : in  std_logic;
waddr_prot    : in  std_logic_vector(34 downto 0);
waddr_ren     : out std_logic;
waddr_fe      : in  std_logic;
wdata_strb    : in  std_logic_vector(35 downto 0);
data_ren      : out std_logic;
data_fe       : in  std_logic;
raddr_prot    : in  std_logic_vector(34 downto 0);
raddr_ren     : out std_logic;
raddr_fe      : in  std_logic;
rdata_serr    : out std_logic_vector(32 downto 0);
rdata_wen     : out std_logic;
rdata_ff      : in  std_logic;
wr_resp_2_axi : out std_logic;
wr_2_axi      : out std_logic;
rd_2_axi      : out std_logic;
access_ratio  : in  std_logic_vector(2 downto 0)
);
end component;

component master_interface is
generic (
AW : integer := 32;
DW : integer := 32
);
port (
-- APB4 Master Interface Signals
PSELx          : out std_logic;
PCLK           : in  std_logic;
PRESETn        : in  std_logic;
PADDR          : out std_logic_vector(31 downto 0);
PENABLE        : out std_logic;
PWRITE         : out std_logic;
PPROT          : out std_logic_vector(2 downto 0);
PWDATA         : out std_logic_vector(DW-1 downto 0);
PSTRB          : out std_logic_vector((DW/8)-1 downto 0);
PREADY         : in  std_logic;
PRDATA         : in  std_logic_vector(DW-1 downto 0);
PSLVERR        : in  std_logic;

-- internal signals
use_1clk       : in  std_logic;
wr_rd_ratio    : in  std_logic_vector(2 downto 0);
wa_fifo_rdata  : in  std_logic_vector(AW+2 downto 0);
wa_fifo_pop    : out std_logic;
wa_fifo_empty  : in  std_logic;
wd_fifo_rdata  : in  std_logic_vector((DW/8)+DW-1 downto 0);
wd_fifo_pop    : out std_logic;
wd_fifo_empty  : in  std_logic;
ra_fifo_rdata  : in  std_logic_vector(AW+2 downto 0);
ra_fifo_pop    : out std_logic;
ra_fifo_empty  : in  std_logic;
rd_fifo_wdata  : out std_logic_vector(DW downto 0);
rd_fifo_push   : out std_logic;
rd_fifo_full   : in  std_logic;
wr_resp_2_axi  : out std_logic;
wr_2_axi       : out std_logic;
rd_2_axi       : out std_logic;
wa_addr_prot   : in  std_logic_vector(AW+2 downto 0);
wa_wen         : in  std_logic;
wa_ready       : out std_logic;
wd_data_strb   : in  std_logic_vector((DW/8)+DW-1 downto 0);
wd_wen         : in  std_logic;
wd_ready       : out std_logic;
ra_addr_prot   : in  std_logic_vector(AW+2 downto 0);
ra_wen         : in  std_logic;
ra_ready       : out std_logic;
rd_data_slverr : out std_logic_vector(DW downto 0);
rd_ready       : in  std_logic;
rd_valid       : out std_logic;
b_ready        : in  std_logic;
b_valid        : out std_logic;
b_resp         : out std_logic
);
end component;

component apb_slave_int is
port (
-- APB Interface Signals
PSELx   : in  std_logic;
PCLK    : in  std_logic;
PRESETn : in  std_logic;
PENABLE : in  std_logic;
PADDR   : in  std_logic_vector(31 downto 0);
PWRITE  : in  std_logic;
PWDATA  : in  std_logic_vector(31 downto 0);
PRDATA  : out std_logic_vector(31 downto 0);

--internal Signals
wen     : out std_logic;
waddr   : out std_logic_vector(31 downto 0);
wdata   : out std_logic_vector(31 downto 0);
ren     : out std_logic;
raddr   : out std_logic_vector(31 downto 0);
rdata   : in  std_logic_vector(31 downto 0)
);
end component;

component config_status_reg is
port (
-- Interface Signals
rstn                     : in  std_logic;
clk                      : in  std_logic;
wen                      : in  std_logic;
waddr                    : in  std_logic_vector(31 downto 0);
wdata                    : in  std_logic_vector(31 downto 0);
ren                      : in  std_logic;
raddr                    : in  std_logic_vector(31 downto 0);
rdata                    : out std_logic_vector(31 downto 0);

-- Internal Signals
axi_rd                   : in  std_logic;
axi_wr                   : in  std_logic;
mstr_rd                  : in  std_logic;
mstr_wr                  : in  std_logic;
mst_config_wr_rd_ratio   : out std_logic_vector(2 downto 0);
slv_config_use_merr_resp : out std_logic;
sample_data              : in  std_logic_vector(31 downto 0);
sample_reg_wr            : in  std_logic;
sample_reg_rd            : out std_logic;
sample_conf_ctrl         : out std_logic_vector(15 downto 0)
);
end component;

component csr_interface_apb is
generic (AW: integer := 32;
         DW: integer := 32
);
port (
-- APB Interface Signals
PSELx         : in  std_logic;
PCLK          : in  std_logic;
PRESETn       : in  std_logic;
PENABLE       : in  std_logic;
PADDR         : in  std_logic_vector(31 downto 0);
PWRITE        : in  std_logic;
PWDATA        : in  std_logic_vector(31 downto 0);
PRDATA        : out std_logic_vector(31 downto 0);

-- internal signals
axi_rd        : in  std_logic;
axi_wr        : in  std_logic;
mstr_rd       : in  std_logic;
mstr_wr       : in  std_logic;
wr_rd_ratio   : out std_logic_vector(2 downto 0);
use_merr_resp : out std_logic;
wa            : in  std_logic_vector(AW+2 downto 0);
wa_vld        : in  std_logic;
wd            : in  std_logic_vector(DW-1 downto 0);
wd_vld        : in  std_logic;
ra            : in  std_logic_vector(AW+2 downto 0);
ra_vld        : in  std_logic;
rd            : in  std_logic_vector(DW-1 downto 0);
rd_vld        : in  std_logic;
mclk          : in  std_logic;
mrstn         : in  std_logic
);
end component;

component axi4lite_slave is
generic (
AW : integer := 32;
DW : integer := 32
);
port (
-- AXI4 Slave Signals
ACLK           : in  std_logic;
ARESETn        : in  std_logic;
-- WA Channel
AWADDR         : in  std_logic_vector(AW-1 downto 0);
AWPROT         : in  std_logic_vector(2 downto 0);
AWVALID        : in  std_logic;
AWREADY        : out std_logic;
-- WD Channel
WDATA          : in  std_logic_vector(DW-1 downto 0);
WSTRB          : in  std_logic_vector((DW/8)-1 downto 0);
WVALID         : in  std_logic;
WREADY         : out std_logic;
-- WR Channel
BRESP          : out std_logic_vector(1 downto 0);
BVALID         : out std_logic;
BREADY         : in  std_logic;
-- RA Channel
ARADDR         : in  std_logic_vector(AW-1 downto 0);
ARPROT         : in  std_logic_vector(2 downto 0);
ARVALID        : in  std_logic;
ARREADY        : out std_logic;
-- RD Channel
RDATA          : out std_logic_vector(DW-1 downto 0);
RRESP          : out std_logic_vector(1 downto 0);
RVALID         : out std_logic;
RREADY         : in  std_logic;

-- internal signals
use_1clk       : in  std_logic;

w_addr_prot    : out std_logic_vector(AW+2 downto 0);
w_addr_wen     : out std_logic;
w_addr_full    : in  std_logic;

w_data_strb    : out std_logic_vector((DW/8)+DW-1 downto 0);
w_data_wen     : out std_logic;
w_data_full    : in  std_logic;

r_addr_prot    : out std_logic_vector(AW+2 downto 0);
r_addr_wen     : out std_logic;
r_addr_full    : in  std_logic;

r_data_err     : in std_logic_vector(DW downto 0);
r_data_ren     : out std_logic;
r_data_empty   : in  std_logic;

wr_resp_2_axi  : in  std_logic;
mstr_wr_2_axi  : in  std_logic;
use_mwerr_resp : in  std_logic;

wa_ready       : in  std_logic;
wd_ready       : in  std_logic;
ra_ready       : in  std_logic;
rd_data_slverr : in  std_logic_vector(DW downto 0);
rd_ready       : out std_logic;
rd_valid       : in  std_logic;
b_ready        : out std_logic;
b_valid        : in  std_logic;
b_resp         : in  std_logic
);
end component;


end components;
