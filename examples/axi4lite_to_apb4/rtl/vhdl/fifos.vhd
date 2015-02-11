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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - FIFO wrapper 
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/14/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

entity fifos is
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
end entity;

architecture rtl of fifos is

begin

-- FIFO instantiations
u_wafifo: dp_fifo
generic map (AW => 2, DW => DW+3) 
port map (
wrstn => s_rstn,
wclk  => s_clk,
rrstn => m_rstn,
rclk  => m_clk,
push  => wa_push,
pop   => wa_pop,
wdata => wa_wdata,
rdata => wa_rdata,
empty => wa_empty,
full  => wa_full
);

u_wdfifo: dp_fifo 
generic map (AW => 2, DW => (DW/8)+DW) 
port map (
wrstn => s_rstn,
wclk  => s_clk,
rrstn => m_rstn,
rclk  => m_clk,
push  => wd_push,
pop   => wd_pop,
wdata => wd_wdata,
rdata => wd_rdata,
empty => wd_empty,
full  => wd_full
);

u_rafifo: dp_fifo 
generic map (AW => 2, DW => DW+3) 
port map (
wrstn => s_rstn,
wclk  => s_clk,
rrstn => m_rstn,
rclk  => m_clk,
push  => ra_push,
pop   => ra_pop,
wdata => ra_wdata,
rdata => ra_rdata,
empty => ra_empty,
full  => ra_full
);

u_rdfifo: dp_fifo 
generic map (AW => 2, DW => DW+1) 
port map (
wrstn => m_rstn,
wclk  => m_clk,
rrstn => s_rstn,
rclk  => s_clk,
push  => rd_push,
pop   => rd_pop,
wdata => rd_wdata,
rdata => rd_rdata,
empty => rd_empty,
full  => rd_full
);

end rtl;
