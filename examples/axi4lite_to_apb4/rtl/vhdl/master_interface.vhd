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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - Master Interface
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/12/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

entity master_interface is
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
end entity;

architecture rtl of master_interface is

-- signal definitions
signal n_pselx_sc   : std_logic;
signal n_paddr_sc   : std_logic_vector(31 downto 0);
signal n_penable_sc : std_logic;
signal n_pwrite_sc  : std_logic;
signal n_pprot_sc   : std_logic_vector(2 downto 0);
signal n_pwdata_sc  : std_logic_vector(DW-1 downto 0);
signal n_pstrb_sc   : std_logic_vector((DW/8) -1 downto 0);
signal n_pready_sc  : std_logic;
signal n_prdata_sc  : std_logic_vector(DW-1 downto 0);
signal n_pslverr_sc : std_logic;

signal n_pselx_mc   : std_logic;
signal n_paddr_mc   : std_logic_vector(31 downto 0);
signal n_penable_mc : std_logic;
signal n_pwrite_mc  : std_logic;
signal n_pprot_mc   : std_logic_vector(2 downto 0);
signal n_pwdata_mc  : std_logic_vector(DW-1 downto 0);
signal n_pstrb_mc   : std_logic_vector((DW/8) -1 downto 0);
signal n_pready_mc  : std_logic;
signal n_prdata_mc  : std_logic_vector(DW-1 downto 0);
signal n_pslverr_mc : std_logic;

begin

-- instantiations

u_pinmux: pinmux
generic map (AW => AW, DW => DW) 
port map (
-- APB4 Master Interface Signals
PSELx      => PSELx,
PADDR      => PADDR,
PENABLE    => PENABLE,
PWRITE     => PWRITE,
PPROT      => PPROT,
PWDATA     => PWDATA,
PSTRB      => PSTRB,
PREADY     => PREADY,
PRDATA     => PRDATA,
PSLVERR    => PSLVERR,

-- Single clock signals
pselx_sc   => n_pselx_sc,
paddr_sc   => n_paddr_sc,
penable_sc => n_penable_sc,
pwrite_sc  => n_pwrite_sc,
pprot_sc   => n_pprot_sc,
pwdata_sc  => n_pwdata_sc,
pstrb_sc   => n_pstrb_sc,
pready_sc  => n_pready_sc,
prdata_sc  => n_prdata_sc,
pslverr_sc => n_pslverr_sc,

-- Multi clock signals
pselx_mc   => n_pselx_mc,
paddr_mc   => n_paddr_mc,
penable_mc => n_penable_mc,
pwrite_mc  => n_pwrite_mc,
pprot_mc   => n_pprot_mc,
pwdata_mc  => n_pwdata_mc,
pstrb_mc   => n_pstrb_mc,
pready_mc  => n_pready_mc,
prdata_mc  => n_prdata_mc,
pslverr_mc => n_pslverr_mc,

-- other signals
use_1clk => use_1clk
);


u_apb_master_sc: apb_master_sc
port map (
-- APB4 Interface Signals
PCLK         => PCLK,
PRESETn      => PRESETn,
PSELx        => n_pselx_sc,
PENABLE      => n_penable_sc,
PADDR        => n_paddr_sc,
PPROT        => n_pprot_sc,
PWRITE       => n_pwrite_sc,
PWDATA       => n_pwdata_sc,
PSTRB        => n_pstrb_sc,  -- drive low for reads
PREADY       => n_pready_sc,
PRDATA       => n_prdata_sc,
PSLVERR      => n_pslverr_sc, -- can tie 0 if not used

--internal Signals
use_1clk     => use_1clk,
waddr_prot   => wa_addr_prot,
waddr_wen    => wa_wen,
waddr_ready  => wa_ready,
wdata_strb   => wd_data_strb,
wdata_wen    => wd_wen,
wdata_ready  => wd_ready,
raddr_prot   => ra_addr_prot,
raddr_wen    => ra_wen,
raddr_ready  => ra_ready,
rdata_slverr => rd_data_slverr,
rdata_ready  => rd_ready,
rdata_valid  => rd_valid,
bready       => b_ready,
bvalid       => b_valid,
bresp        => b_resp
);


u_apb_master_mc: apb_master_mc 
port map (
-- APB4 Interface Signals
PCLK          => PCLK,
PRESETn       => PRESETn,
PSELx         => n_pselx_mc,
PENABLE       => n_penable_mc,
PADDR         => n_paddr_mc,
PPROT         => n_pprot_mc,
PWRITE        => n_pwrite_mc,
PWDATA        => n_pwdata_mc,
PSTRB         => n_pstrb_mc,
PREADY        => n_pready_mc,
PSLVERR       => n_pslverr_mc,
PRDATA        => n_prdata_mc,
use_1clk      => use_1clk,
waddr_prot    => wa_fifo_rdata,
waddr_ren     => wa_fifo_pop,
waddr_fe      => wa_fifo_empty,
wdata_strb    => wd_fifo_rdata,
data_ren      => wd_fifo_pop,
data_fe       => wd_fifo_empty,
raddr_prot    => ra_fifo_rdata,
raddr_ren     => ra_fifo_pop,
raddr_fe      => ra_fifo_empty,
rdata_serr    => rd_fifo_wdata,
rdata_wen     => rd_fifo_push,
rdata_ff      => rd_fifo_full,
wr_resp_2_axi => wr_resp_2_axi,
wr_2_axi      => wr_2_axi,
rd_2_axi      => rd_2_axi,
access_ratio  => wr_rd_ratio
);

end rtl;
