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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - AXI4-Lite Slave Interface 
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/15/15
-- Notes: will plan to support 4 addr commands before holding with ready. 
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;
 
entity axi4lite_slave is
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
end entity;

architecture rtl of axi4lite_slave is

-- internal signals
constant WR_IDLE            : std_logic_vector := "0001";
constant WR_IRESP           : std_logic_vector := "0010";
constant WR_WRESP           : std_logic_vector := "0100";
constant WR_MRESP           : std_logic_vector := "1000";
constant RR_IDLE            : std_logic_vector := "01";
constant RR_RESP_MC         : std_logic_vector := "10";
signal wr_cstate, wr_nstate : std_logic_vector(3 downto 0);
signal rr_cstate, rr_nstate : std_logic_vector(1 downto 0);

signal rdata_2_axi_s        : std_logic_vector(DW-1 downto 0);
signal rd_resp_2_axi_s      : std_logic;
signal rd_resp_2_axi_s_d    : std_logic;
signal rd_vld_2_axi_s       : std_logic;
signal wr_resp_2_axi_s      : std_logic;
signal wr_resp_2_axi_s_d    : std_logic;
signal mstr_wr_2_axi_s      : std_logic;

signal not_w_addr_full      : std_logic;
signal not_w_data_full      : std_logic;
signal not_r_addr_full      : std_logic;
signal RR_RESP_MC_bit       : std_logic;

begin

-- axi4lite_slave rtl

-- WA Channel
w_addr_prot     <= (AWPROT&AWADDR);
w_addr_wen      <= AWVALID and AWREADY;
not_w_addr_full <= not w_addr_full;

u_mux_awready: MUX2to1_bit
port map (
di0  => not_w_addr_full,
di1  => wa_ready,
sel  => use_1clk,
dout => AWREADY
);


-- WD Channel
w_data_strb     <= (WSTRB&WDATA);
w_data_wen      <= WVALID and WREADY;
not_w_data_full <= not w_data_full;

u_mux_wready: MUX2to1_bit
port map (
di0  => not_w_data_full,
di1  => wd_ready,
sel  => use_1clk,
dout => WREADY
);


-- WR Channel (either next cycle response or use master side response)
b_ready <= BREADY;

process (use_1clk,b_resp,wr_cstate,wr_resp_2_axi_s_d,wr_resp_2_axi_s,mstr_wr_2_axi_s)
begin
if (use_1clk = '1') then
	BRESP <= (b_resp&'0');
elsif (wr_cstate = WR_MRESP) then
	BRESP <= (wr_resp_2_axi_s_d&'0');
elsif ((wr_cstate = WR_WRESP) and (mstr_wr_2_axi_s = '1')) then
	BRESP <= (wr_resp_2_axi_s&'0');
else
	BRESP <= "00";
end if;
end process;

BVALID <= b_valid when (use_1clk = '1') else 
          '1'     when ((use_mwerr_resp = '1') and (((wr_cstate = WR_WRESP) and (mstr_wr_2_axi_s = '1')) or (wr_cstate = WR_MRESP))) else
          '1'     when (wr_cstate = WR_IRESP) else '0';

process (ACLK,ARESETn)
begin
if (ARESETn = '0') then
	wr_cstate <= WR_IDLE;
elsif (ACLK'event and ACLK = '1') then
	wr_cstate <= wr_nstate;
end if;
end process;

process (wr_cstate,use_mwerr_resp,w_data_wen,BREADY,mstr_wr_2_axi_s)
begin
case wr_cstate is
when WR_IDLE => if ((use_mwerr_resp = '0') and (w_data_wen = '1')) then
		wr_nstate <= WR_IRESP;
	elsif ((use_mwerr_resp = '1') and (w_data_wen = '1')) then
		wr_nstate <= WR_WRESP;
	else
		wr_nstate <= WR_IDLE;
	end if;
when WR_IRESP => if ((BREADY = '1') and (w_data_wen = '1')) then
		wr_nstate <= WR_IRESP;
	elsif (BREADY = '1') then
		wr_nstate <= WR_IDLE;
	else
		wr_nstate <= WR_IRESP;
	end if;
when WR_WRESP => if ((mstr_wr_2_axi_s = '1') and (BREADY = '1')) then
		wr_nstate <= WR_IDLE;
	else
		wr_nstate <= WR_MRESP;
	end if;
when WR_MRESP => if (BREADY = '1') then
                wr_nstate <= WR_IDLE;
        else
                wr_nstate <= WR_MRESP;
	end if;
when others => wr_nstate <= WR_IDLE;
end case;
end process;

u_wr_resp_2_axi: pulse_sync
port map (
rstn => ARESETn,
clk  => ACLK,
d    => wr_resp_2_axi,
p    => wr_resp_2_axi_s
);

u_mstr_wr_2_axi: pulse_sync
port map (
rstn => ARESETn,
clk  => ACLK,
d    => mstr_wr_2_axi,
p    => mstr_wr_2_axi_s
);

process (ACLK,ARESETn)
begin
if (ARESETn = '0') then
	wr_resp_2_axi_s_d <= '0';
elsif (ACLK'event and ACLK = '1') then
	if (wr_cstate = WR_IDLE) then
		wr_resp_2_axi_s_d <= '0';
	elsif (mstr_wr_2_axi_s = '1') then
		wr_resp_2_axi_s_d <= wr_resp_2_axi_s;
	else
		wr_resp_2_axi_s_d <= wr_resp_2_axi_s_d;
	end if;
end if;
end process;



-- RA Channel
r_addr_prot     <= (ARPROT&ARADDR);
r_addr_wen      <= ARVALID and ARREADY;
not_r_addr_full <= not r_addr_full;

u_mux_arready: MUX2to1_bit
port map (
di0  => not_r_addr_full,
di1  => ra_ready,
sel  => use_1clk,
dout => ARREADY
);


-- RD Channel
u_mux_rdata: MUX2to1_bus
generic map (DWIDTH => 32) 
port map (
di0  => r_data_err(31 downto 0),
di1  => rd_data_slverr(31 downto 0),
sel  => use_1clk,
dout => RDATA
);

u_mux_rresp: MUX2to1_bus 
generic map (DWIDTH => 2)
port map (
di0  => (r_data_err(32)&'0'),
di1  => (rd_data_slverr(32)&'0'),
sel  => use_1clk,
dout => RRESP
);

RR_RESP_MC_bit <= '1' when (rr_cstate = RR_RESP_MC) else '0';
u_mux_rvalid: MUX2to1_bit 
port map (
di0  => RR_RESP_MC_bit,
di1  => rd_valid,
sel  => use_1clk,
dout => RVALID
);

r_data_ren <= '1' when ((rr_cstate = RR_IDLE) and (r_data_empty = '0')) else '0';
rd_ready   <= RREADY;

process (ACLK,ARESETn)
begin
if (ARESETn = '0') then
        rr_cstate <= RR_IDLE;
elsif (ACLK'event and ACLK = '1') then
        rr_cstate <= rr_nstate;
end if;
end process;

process (rr_cstate,use_1clk,r_data_empty,RREADY)
begin
case rr_cstate is
when RR_IDLE => if ((use_1clk = '0') and (r_data_empty = '0')) then
                rr_nstate <= RR_RESP_MC;
        else
                rr_nstate <= RR_IDLE;
	end if;
when RR_RESP_MC => if (RREADY = '1') then
                rr_nstate <= RR_IDLE;
        else
                rr_nstate <= RR_RESP_MC;
	end if;
when others => rr_nstate <= RR_IDLE;
end case;
end process;

end rtl;
