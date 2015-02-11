-- ************************************************************************
--                Copyright 2006-2015 Mentor Graphics Corporation
--                             All Rights Reserved.
-- 
--                THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
--              INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
--             CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE
--                                    TERMS.
-- 
--  ************************************************************************
-- 
--  DESCRIPTION   : AXI4Lite to APB4 Bridge - Library Modules 
--  AUTHOR        : Mark Eslinger
--  Last Modified : 1/15/15
-- 
--  ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

-- 2to1 MUX  bus bit
entity MUX2to1_bit is
port (
di0  : in  std_logic;
di1  : in  std_logic;
sel  : in  std_logic;
dout : out std_logic
);
end entity;

architecture rtl of MUX2to1_bit is
begin

dout <= di1 when (sel = '1') else di0;

end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

-- 2to1 MUX  bus
entity MUX2to1_bus is
generic (DWIDTH : integer := 1);
port (
di0  : in  std_logic_vector(DWIDTH-1 downto 0);
di1  : in  std_logic_vector(DWIDTH-1 downto 0);
sel  : in  std_logic;
dout : out std_logic_vector(DWIDTH-1 downto 0)
);
end entity;

architecture rtl of MUX2to1_bus is
begin

dout <= di1 when (sel = '1') else di0;

end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

-- 1to2 DECODER bit
entity DEC1to2_bit is
port (
di  : in  std_logic;
sel : in  std_logic;
do0 : out std_logic;
do1 : out std_logic
);
end entity;

architecture rtl of DEC1to2_bit is
begin

do0 <= '0' when (sel = '1') else  di;
do1 <= di  when (sel = '1') else '0';

end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

-- 1to2 DECODER bus
entity DEC1to2_bus is
generic (DWIDTH : integer := 1);
port (
di  : in  std_logic_vector(DWIDTH-1 downto 0);
sel : in  std_logic;
do0 : out std_logic_vector(DWIDTH-1 downto 0);
do1 : out std_logic_vector(DWIDTH-1 downto 0)
);
end entity;

architecture rtl of DEC1to2_bus is
begin 

do0 <= (others => '0') when (sel = '1') else  di;
do1 <= di              when (sel = '1') else  (others => '0'); 

end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;


-- 2DFF sync
entity sync_2dff is
generic (DW : integer := 1);
port (
rstn : in  std_logic;
clk  : in  std_logic;
d    : in  std_logic_vector(DW-1 downto 0);
q    : out std_logic_vector(DW-1 downto 0)
);
end entity;

architecture rtl of sync_2dff is

signal meta : std_logic_vector(DW-1 downto 0);

begin

process (clk,rstn)
begin
if (rstn = '0') then 
	meta <= (others => '0');
	q    <= (others => '0');
elsif (clk'event and clk = '1') then
        meta <= d;
        q    <= meta;
end if;
end process;

end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

-- Pulse Sync (rising edge only)
entity pulse_sync is 
port (
rstn : in  std_logic;
clk  : in  std_logic;
d    : in  std_logic;
p    : out std_logic
);
end entity;

architecture rtl of pulse_sync is

signal meta1, meta2, meta3, not_meta2 : std_logic;

begin

not_meta2 <= not meta2;

process (clk, rstn)
begin
if (rstn = '0') then 
        meta1 <= '0';
        meta2 <= '0';
        meta3 <= '0';
elsif (clk'event and clk = '1') then
        meta1 <= d;
        meta2 <= meta1;
        meta3 <= not_meta2;
end if;
end process;

p <= meta2 and meta3;

end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;


-- DMUX sync w pulse sync
entity psync_dmux is 
generic (DWIDTH : integer := 1);
port (
rstn : in  std_logic;
clk  : in  std_logic;
sel  : in  std_logic;
din  : in  std_logic_vector(DWIDTH-1 downto 0);
dout : out std_logic_vector(DWIDTH-1 downto 0)
);
end entity;

architecture rtl of psync_dmux is 

signal s_sel : std_logic;

begin

u1: pulse_sync
port map (
rstn => rstn, 
clk  => clk, 
d    => sel, 
p    => s_sel 
);

process (clk,rstn)
begin
if (rstn = '0') then
	dout <= (others => '0');
elsif (clk'event and clk = '1') then
	if (s_sel = '1') then
		dout <= din;
	else
		dout <= dout;
	end if;
end if;
end process;

end rtl;

