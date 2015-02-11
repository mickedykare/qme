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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - Dual Port FIFO 
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/14/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

entity dp_fifo is
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
end entity;

architecture rtl of dp_fifo is

-- Local signal definitions 
signal wp_binary, wp_gray           : std_logic_vector(AW downto 0);
signal wp_binary_next, wp_gray_next : std_logic_vector(AW downto 0);

signal rp_binary, rp_gray           : std_logic_vector(AW downto 0);
signal rp_binary_next, rp_gray_next : std_logic_vector(AW downto 0);

signal wp_sync_2r, wp_meta          : std_logic_vector(AW downto 0);
signal rp_sync_2w, rp_meta          : std_logic_vector(AW downto 0);
signal rp_sync_2w_2binary           : std_logic_vector(AW downto 0);

signal nxt_empty                    : std_logic;
signal nxt_full                     : std_logic;

begin

-- Dual Port Memory 
fifo_mem: dp_sram
generic map (
AW => AW, 
DW => DW
) 
port map (
wclk  => wclk,
rclk  => rclk,
waddr => wp_binary(AW-1 downto 0),
raddr => rp_binary(AW-1 downto 0),
wdata => wdata,
rdata => rdata,
wen   => push,
ren   => pop
);


-- Push/Pop Pointer Logic
process (wclk,wrstn)
begin
if(wrstn = '0') then
	wp_binary <= (others => '0');
elsif (wclk'event and wclk = '1') then
	if (push = '1') then
		wp_binary <= wp_binary_next;
	else
		wp_binary <= wp_binary;
	end if;
end if;
end process;

process (wclk,wrstn)
begin
if (wrstn = '0') then
	wp_gray <= (others => '0');
elsif (wclk'event and wclk = '1') then
	if (push = '1') then
		wp_gray <= wp_gray_next;
	else
		wp_gray <= wp_gray;
	end if;
end if;
end process;

wp_binary_next <= wp_binary + '1';
wp_gray_next   <= wp_binary_next xor ('0'&wp_binary_next(AW downto 1));

process (rclk,rrstn)
begin
if(rrstn = '0') then
	rp_binary <= (others => '0');
elsif (rclk'event and rclk = '1') then
	if (pop = '1') then
		rp_binary <= rp_binary_next;
	else
		rp_binary <= rp_binary;
	end if;
end if;
end process;

process (rclk,rrstn)
begin
if (rrstn = '0') then
	rp_gray <= (others => '0');
elsif (rclk'event and rclk = '1') then
	if (pop = '1') then
		rp_gray <= rp_gray_next;
	else
		rp_gray <= rp_gray;
	end if;
end if;
end process;

rp_binary_next  <= rp_binary + '1';
rp_gray_next    <= rp_binary_next xor ('0'&rp_binary_next(AW downto 1));


-- Gray Pointer Synchronizers
process (rclk,rrstn)
begin
if (rrstn = '0') then 
	wp_meta    <= (others => '0');
	wp_sync_2r <= (others => '0');
elsif (rclk'event and rclk = '1') then
	wp_meta    <= wp_gray;
	wp_sync_2r <= wp_meta;
end if;
end process;

process (wclk,wrstn)
begin
if (wrstn = '0') then 
        rp_meta    <= (others => '0');
        rp_sync_2w <= (others => '0');
elsif (wclk'event and wclk = '1') then
        rp_meta    <= rp_gray;
        rp_sync_2w <= rp_meta;
end if;
end process;


-- Generate Full and Empty Flags 
rp_sync_2w_2binary <= rp_sync_2w xor ('0'&rp_sync_2w_2binary(AW downto 1));

nxt_full <= '1' when (((wp_binary(AW-1 downto 0) = rp_sync_2w_2binary(AW-1 downto 0)) and (wp_binary(AW) /= rp_sync_2w_2binary(AW))) or
                (((push = '1') and (wp_binary_next(AW-1 downto 0) = rp_sync_2w_2binary(AW-1 downto 0))) and 
                   (wp_binary_next(AW) /= rp_sync_2w_2binary(AW))) ) else '0';

process (wclk,wrstn)
begin
if (wrstn = '0') then
	full <= '0';
elsif (wclk'event and wclk = '1') then
	full <= nxt_full; 
end if;
end process;

nxt_empty <= '1' when ((wp_sync_2r = rp_gray) or ((pop = '1') and (wp_sync_2r = rp_gray_next))) else '0';

process (rclk,rrstn)
begin
if (rrstn = '0') then
	empty <= '1';
elsif (rclk'event and rclk = '1') then
	empty <= nxt_empty;
end if;
end process;


end rtl;
