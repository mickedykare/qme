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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - APB Slave Interface 
--			Interface to Config/Status Register
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/14/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity apb_slave_int is
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
end entity;

architecture rtl of apb_slave_int is

-- signal definitions
signal pselx_d   : std_logic;
signal penable_d : std_logic;
signal pwrite_d  : std_logic;

begin

-- Convert APB signals to config/status bus 
process (PCLK, PRESETn)
begin
if (PRESETn = '0') then
	pselx_d   <= '0';
	penable_d <= '0';
	pwrite_d  <= '0';
elsif (PCLK'event and PCLK = '1') then
        pselx_d   <= PSELx;
        penable_d <= PENABLE;
        pwrite_d  <= PWRITE;
end if;
end process;

wen    <= (pselx_d and PSELx and not penable_d and PENABLE and     pwrite_d and     PWRITE);
waddr  <= PADDR;
wdata  <= PWDATA;
ren    <= (pselx_d and PSELx and not penable_d and PENABLE and not pwrite_d and not PWRITE);
raddr  <= PADDR;
PRDATA <= rdata;

end rtl;
