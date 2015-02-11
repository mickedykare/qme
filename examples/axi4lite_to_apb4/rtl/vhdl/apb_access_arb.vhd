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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - APB Access Arbiter 
--                 Arbitrates between read/write access channels
--                 when data is available from both
--                 000 -  1 rd per 1 wr 
--                 001 -  1 rd per 1 wr
--                 010 -  2 rd per 1 wr
--                 011 -  3 rd per 1 wr
--                 100 -  1 wr per 1 rd
--                 101 -  1 wr per 1 rd
--                 110 -  2 wr per 1 rd
--                 111 -  3 wr per 1 rd
--                 If only 1 side is ready it gets serviced
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/12/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity apb_access_arb is
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
end entity;

architecture rtl of apb_access_arb is

-- definitions
constant IDLE    : std_logic_vector(4 downto 0) := "00001";
constant RSETUP  : std_logic_vector(4 downto 0) := "00010";
constant RACTIVE : std_logic_vector(4 downto 0) := "00100"; 
constant WSETUP  : std_logic_vector(4 downto 0) := "01000";
constant WACTIVE : std_logic_vector(4 downto 0) := "10000";

signal cstate, nstate : std_logic_vector(4 downto 0);

signal cmd        : std_logic;
signal cmd_cnt    : std_logic_vector(1 downto 0);
signal both_avail : std_logic;
signal r_avail    : std_logic;

begin

-- logic
cmd <= wr when (ratio(2) = '1') else  rd;

process (clk,rstn)
begin
if (rstn = '0') then
	cmd_cnt <= "00";
elsif (clk'event and clk = '1') then
	if (cstate = IDLE) then
		cmd_cnt <= "00";
	elsif (ratio(1 downto 0) <= "01") then
		cmd_cnt <= "00";
	elsif (cmd_cnt = ratio(1 downto 0)) then
		cmd_cnt <= "00";
	elsif (cmd = '1') then
		cmd_cnt <= cmd_cnt + 1;
	else
		cmd_cnt <= cmd_cnt;
	end if;
end if;
end process;

process (clk,rstn)
begin
if (rstn = '0') then 
	cstate <= IDLE;
elsif (clk'event and clk = '1') then
	cstate <= nstate;
end if;
end process;

r_avail     <= ra_avail and rd_avail;
both_avail  <= ra_avail and wr_avail;

process (cstate,r_avail,wr_avail,both_avail,ratio,rd,wr,cmd_cnt)
begin
case cstate is
when IDLE => if ((r_avail = '1') and (wr_avail = '0')) then
		nstate <= RACTIVE;
	elsif ((r_avail = '0') and (wr_avail = '1')) then
		nstate <= WACTIVE;
	elsif ((both_avail = '1') and (ratio(2) = '1')) then
		nstate <= WACTIVE;
	elsif ((both_avail = '1') and (ratio(2) = '0')) then
		nstate <= RACTIVE;
	else
		nstate <= IDLE;
	end if;
when RSETUP => if ((rd = '1') or (wr = '1')) then
		nstate <= RACTIVE;
	else
		nstate <= RSETUP;
	end if;
when RACTIVE => if ((r_avail = '1') and (wr_avail = '0')) then
		nstate <= RSETUP;
	elsif ((r_avail = '0') and (wr_avail = '1')) then
		nstate <= WSETUP;
	elsif ((both_avail = '1') and (ratio(2) = '1')) then
		nstate <= WSETUP;
	elsif ((both_avail = '1') and (ratio(2) = '0') and (ratio(1 downto 0) <= "01")) then
		nstate <= WSETUP;
	elsif ((both_avail = '1') and (ratio(2) = '0') and (cmd_cnt = ratio(1 downto 0))) then
		nstate <= WSETUP;
	elsif ((both_avail = '1') and (ratio(2) = '0') and (cmd_cnt <= ratio(1 downto 0))) then
		nstate <= RSETUP;
	else
		nstate <= IDLE;
	end if;
when WSETUP => if ((rd = '1') or (wr = '1')) then
		nstate <= WACTIVE;
	else
		nstate <= WSETUP;
	end if;
when WACTIVE => if ((r_avail = '1') and (wr_avail = '0')) then
                nstate <= RSETUP;
        elsif ((r_avail = '0') and (wr_avail = '1')) then
                nstate <= WSETUP;
        elsif ((both_avail = '1') and (ratio(2) = '0')) then
                nstate <= RSETUP;
        elsif ((both_avail = '1') and (ratio(2) = '1') and (ratio(1 downto 0) <= "01")) then
                nstate <= RSETUP;
        elsif ((both_avail = '1') and (ratio(2) = '1') and (cmd_cnt = ratio(1 downto 0))) then
                nstate <= RSETUP;
        elsif ((both_avail = '1') and (ratio(2) = '1') and (cmd_cnt <= ratio(1 downto 0))) then
                nstate <= WSETUP;
        else
                nstate <= IDLE;
	end if;
when others => nstate <= IDLE;
end case;
end process;

process (cstate,r_avail,wr_avail,ratio,both_avail,rd,wr)
begin
if (cstate = IDLE) then
	if (((r_avail = '1') and (wr_avail = '0')) or ((ratio(2) = '0') and (both_avail = '1')) ) then
		rd_en <= '1';
	else
		rd_en <= '0';
	end if;
elsif (cstate = RSETUP) then
	if ((rd = '1') or (wr = '1')) then
		rd_en <= '1';
	else
		rd_en <= '0';
	end if;
else
	rd_en <= '0';
end if;
end process;

process (cstate,ra_avail,wr_avail,ratio,both_avail,rd,wr)
begin
if (cstate = IDLE) then
        if (((ra_avail = '0') and (wr_avail = '1')) or ((ratio(2) = '1') and (both_avail = '1'))) then
                wr_en <= '1';
        else
                wr_en <= '0';
	end if;
elsif (cstate = WSETUP) then
        if ((rd = '1') or (wr = '1')) then
                wr_en <= '1';
        else
                wr_en <= '0';
	end if;
else
        wr_en <= '0';
end if;
end process;


end rtl;
