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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - APB4 Master Interface Multi-clk
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/14/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;

use work.components.all;

entity apb_master_mc is
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
end entity;

architecture rtl of apb_master_mc is

-- signal definition 
type state is (IDLE,WSETUP,WACTIVE,RSETUP, RACTIVE);
signal cstate, nstate : state;
signal wfifo_ren      : std_logic;
signal apb_rd         : std_logic;
signal apb_wr         : std_logic;
signal not_raddr_fe   : std_logic;
signal not_rdata_ff   : std_logic;
signal not_wa_wd_fe   : std_logic;

begin

-- design code 

PPROT  <= waddr_prot(34 downto 32) when (PWRITE = '1') else raddr_prot(34 downto 32);
PADDR  <= waddr_prot(31 downto 0)  when (PWRITE = '1') else raddr_prot(31 downto 0);
PSTRB  <= wdata_strb(35 downto 32) when (PWRITE = '1') else "0000";
PWDATA <= wdata_strb(31 downto 0);

apb_rd        <= PSELx and PENABLE and not PWRITE and PREADY;
apb_wr        <= PSELx and PENABLE and     PWRITE and PREADY;
rdata_serr    <= (PSLVERR&PRDATA);
rdata_wen     <= apb_rd;
wr_resp_2_axi <= PSLVERR;
wr_2_axi      <= apb_wr;
rd_2_axi      <= apb_rd;

PSELx   <= '1' when (cstate /= IDLE) else '0';
PWRITE  <= '1' when ((cstate = WSETUP)  or (cstate = WACTIVE)) else '0';
PENABLE <= '1' when ((cstate = WACTIVE) or (cstate = RACTIVE)) else '0';

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
	cstate <= IDLE;
elsif (PCLK'event and PCLK = '1') then
	cstate <= nstate;
end if;
end process;

process (cstate,use_1clk,wfifo_ren,raddr_ren,PREADY)
begin
case cstate is
when IDLE   => if ((wfifo_ren = '1') and (use_1clk = '0')) then
		nstate <= WSETUP;
	elsif ((raddr_ren = '1') and (use_1clk = '0')) then
		nstate <= RSETUP;
	else
		nstate <= IDLE;
	end if;
when WSETUP  => nstate <= WACTIVE;
when WACTIVE => if (PREADY = '0') then
		nstate <= WACTIVE;
	 elsif (wfifo_ren = '1') then
		nstate <= WSETUP;
         elsif (raddr_ren = '1') then
		nstate <= RSETUP;
         else
		nstate <= IDLE;
	end if;
when RSETUP  => nstate <= RACTIVE;
when RACTIVE => if (PREADY = '0') then
                nstate <= RACTIVE;
         elsif (raddr_ren = '1') then
                nstate <= RSETUP;
         elsif (wfifo_ren = '1') then
                nstate <= WSETUP;
         else
                nstate <= IDLE;
	end if;
when others => nstate <= IDLE;
end case;
end process;

not_raddr_fe <= not raddr_fe;
not_rdata_ff <= not rdata_ff;
not_wa_wd_fe <= not waddr_fe and not data_fe;

u_apb_access_arb: apb_access_arb 
port map (
rstn     => PRESETn,
clk      => PCLK,
ratio    => access_ratio,
ra_avail => not_raddr_fe,
rd_avail => not_rdata_ff,
wr_avail => not_wa_wd_fe,
rd       => apb_rd,
wr       => apb_wr,
rd_en    => raddr_ren,
wr_en    => wfifo_ren
);

waddr_ren <= wfifo_ren;
data_ren  <= wfifo_ren;

end rtl;
