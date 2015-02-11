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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - Dual Port SRAM (2 clk)
--                 synchronous 1 write port and 1 read port to same memory
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/14/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dp_sram is
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
end entity;

architecture rtl of dp_sram is

-- define memory
constant depth : integer := 2**AW;
type ram_type is array (0 to depth-1) of std_logic_vector(DW-1 downto 0);
signal mem : ram_type;

begin

process (wclk,wen,waddr,wdata)
begin
if (wclk'event and wclk = '1') then
	if (wen = '1') then
		mem(CONV_INTEGER(waddr)) <= wdata;
	end if;
end if;
end process;

process (rclk,ren,raddr,rdata)
begin
if (rclk'event and rclk = '1') then
	if (ren = '1') then
		rdata <= mem(CONV_INTEGER(raddr));
	end if;
end if;
end process;

end rtl;
