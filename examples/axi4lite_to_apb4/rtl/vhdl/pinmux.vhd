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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - Master Interface Pin Mux
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/15/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

entity pinmux is 
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
end entity;

architecture rtl of pinmux is

begin
-- instantiations

u_pselx: MUX2to1_bit
port map (
 di0  => pselx_mc,
 di1  => pselx_sc,
 sel  => use_1clk,
 dout => PSELx
);

u_paddr: MUX2to1_bus
generic map (DWIDTH => 32)
port map (
 di0  => paddr_mc,
 di1  => paddr_sc,
 sel  => use_1clk,
 dout => PADDR
);

u_penable: MUX2to1_bit
port map (
 di0  => penable_mc,
 di1  => penable_sc,
 sel  => use_1clk,
 dout => PENABLE
);

u_pwrite: MUX2to1_bit
port map (
 di0  => pwrite_mc,
 di1  => pwrite_sc,
 sel  => use_1clk,
 dout => PWRITE
);

u_pprot: MUX2to1_bus
generic map (DWIDTH => 3)
port map (
 di0  => pprot_mc,
 di1  => pprot_sc,
 sel  => use_1clk,
 dout => PPROT
);

u_pwdata: MUX2to1_bus
generic map (DWIDTH => DW)
port map (
 di0  => pwdata_mc,
 di1  => pwdata_sc,
 sel  => use_1clk,
 dout => PWDATA
);

u_pstrb: MUX2to1_bus
generic map (DWIDTH => (DW/8))
port map (
 di0  => pstrb_mc,
 di1  => pstrb_sc,
 sel  => use_1clk,
 dout => PSTRB
);

u_pready: DEC1to2_bit
port map (
 di  => PREADY,
 sel => use_1clk,
 do0 => pready_mc,
 do1 => pready_sc
);

u_prdata: DEC1to2_bus
generic map (DWIDTH => DW)
port map (
 di  => PRDATA,
 sel => use_1clk,
 do0 => prdata_mc,
 do1 => prdata_sc
);

u_pslverr: DEC1to2_bit
port map (
 di  => PSLVERR,
 sel => use_1clk,
 do0 => pslverr_mc,
 do1 => pslverr_sc
);

end rtl;
