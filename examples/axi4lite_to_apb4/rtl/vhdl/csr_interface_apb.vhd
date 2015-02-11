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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - CSR Interface (APB)
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/16/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

entity csr_interface_apb is
generic (AW: integer := 32;
         DW: integer := 32 
);
port ( 
-- APB Interface Signals
PSELx         : in  std_logic;
PCLK          : in  std_logic;
PRESETn       : in  std_logic;
PENABLE       : in  std_logic;
PADDR         : in  std_logic_vector(31 downto 0);
PWRITE        : in  std_logic;
PWDATA        : in  std_logic_vector(31 downto 0);
PRDATA        : out std_logic_vector(31 downto 0);

-- internal signals
axi_rd        : in  std_logic;
axi_wr        : in  std_logic;
mstr_rd       : in  std_logic;
mstr_wr       : in  std_logic;
wr_rd_ratio   : out std_logic_vector(2 downto 0);
use_merr_resp : out std_logic;
wa            : in  std_logic_vector(AW+2 downto 0);
wa_vld        : in  std_logic;
wd            : in  std_logic_vector(DW-1 downto 0);
wd_vld        : in  std_logic;
ra            : in  std_logic_vector(AW+2 downto 0);
ra_vld        : in  std_logic;
rd            : in  std_logic_vector(DW-1 downto 0);
rd_vld        : in  std_logic;
mclk          : in  std_logic;
mrstn         : in  std_logic
);
end entity;


architecture rtl of csr_interface_apb is

-- signal definitions
type samp_st is (INIT,POP,LOAD,HOLD);
signal cstate, nstate  : samp_st;
signal w_en            : std_logic;
signal r_en            : std_logic;
signal w_addr          : std_logic_vector(31 downto 0); 
signal w_data          : std_logic_vector(31 downto 0); 
signal r_addr          : std_logic_vector(31 downto 0); 
signal r_data          : std_logic_vector(31 downto 0);
signal sample_dat      : std_logic_vector(31 downto 0);
signal sample_reg_ld   : std_logic;
signal sample_reg_rd   : std_logic;
signal sample_cmd      : std_logic_vector(15 downto 0);
signal sf_fe, sf_ff    : std_logic;
signal sf_push, sf_pop : std_logic;
signal sf_wdata        : std_logic_vector(31 downto 0); 
signal push_wa_n_d     : std_logic;
signal push_wa_n_i     : std_logic;
signal push_wa_p_d     : std_logic;
signal push_wa_p_i     : std_logic;
signal push_wa         : std_logic;
signal push_wd_n_d     : std_logic;
signal push_wd_n_i     : std_logic;
signal push_wd_p_d     : std_logic;
signal push_wd_p_i     : std_logic;
signal push_wd         : std_logic;
signal push_ra_n_d     : std_logic;
signal push_ra_n_i     : std_logic;
signal push_ra_p_d     : std_logic;
signal push_ra_p_i     : std_logic;
signal push_ra         : std_logic;
signal push_rd_n_d     : std_logic;
signal push_rd_n_i     : std_logic;
signal push_rd_p_d     : std_logic;
signal push_rd_p_i     : std_logic;
signal push_rd         : std_logic;
signal ra_d            : std_logic_vector(2 downto 0);

begin

-- instantiations

u_apb_slave_int: apb_slave_int 
port map (
-- APB2 Interface Signals
PSELx   => PSELx,
PCLK    => PCLK,
PRESETn => PRESETn,
PENABLE => PENABLE,
PADDR   => PADDR,
PWRITE  => PWRITE,
PWDATA  => PWDATA,
PRDATA  => PRDATA,
wen     => w_en,
waddr   => w_addr,
wdata   => w_data,
ren     => r_en,
raddr   => r_addr,
rdata   => r_data
);


u_config_status_reg: config_status_reg 
port map (
-- Interface Signals
rstn                     => PRESETn,
clk                      => PCLK,
wen                      => w_en,
waddr                    => w_addr,
wdata                    => w_data,
ren                      => r_en,
raddr                    => r_addr,
rdata                    => r_data,

-- Internal Signals
axi_rd                   => axi_rd,
axi_wr                   => axi_wr,
mstr_rd                  => mstr_rd,
mstr_wr                  => mstr_wr,
mst_config_wr_rd_ratio   => wr_rd_ratio,
slv_config_use_merr_resp => use_merr_resp,
sample_data              => sample_dat,
sample_reg_wr            => sample_reg_ld,
sample_reg_rd            => sample_reg_rd,
sample_conf_ctrl         => sample_cmd
);

-- sample cmd
-- 15  sample waddr normal data
-- 14  sample waddr normal instr
-- 13  sample waddr privileged data
-- 12  sample waddr privileged instr
-- 11  sample wdata normal data
-- 10  sample wdata normal instr
-- 09  sample wdata privileged data
-- 08  sample wdata privileged instr
-- 07  sample raddr normal data
-- 06  sample raddr normal instr
-- 05  sample raddr privileged data
-- 04  sample raddr privileged instr
-- 03  sample rdata normal data
-- 02  sample rdata normal instr
-- 01  sample rdata privileged data
-- 00  sample rdata privileged instr
push_wa_n_d <= '1' when ((sample_cmd(15) = '1') and (wa_vld = '1') and (wa(34 downto 32) = "010")) else '0';
push_wa_n_i <= '1' when ((sample_cmd(14) = '1') and (wa_vld = '1') and (wa(34 downto 32) = "011")) else '0';
push_wa_p_d <= '1' when ((sample_cmd(13) = '1') and (wa_vld = '1') and (wa(34 downto 32) = "110")) else '0';
push_wa_p_i <= '1' when ((sample_cmd(12) = '1') and (wa_vld = '1') and (wa(34 downto 32) = "111")) else '0';
push_wa     <= push_wa_n_d or push_wa_n_i or push_wa_p_d or push_wa_p_i;

push_wd_n_d <= '1' when ((sample_cmd(11) = '1') and (wd_vld = '1') and (wa(34 downto 32) = "010")) else '0';
push_wd_n_i <= '1' when ((sample_cmd(10) = '1') and (wd_vld = '1') and (wa(34 downto 32) = "011")) else '0';
push_wd_p_d <= '1' when ((sample_cmd(9)  = '1') and (wd_vld = '1') and (wa(34 downto 32) = "110")) else '0';
push_wd_p_i <= '1' when ((sample_cmd(8)  = '1') and (wd_vld = '1') and (wa(34 downto 32) = "111")) else '0';
push_wd     <= push_wd_n_d or push_wd_n_i or push_wd_p_d or push_wd_p_i;

push_ra_n_d <= '1' when ((sample_cmd(7)  = '1') and (ra_vld = '1') and (ra(34 downto 32) = "010")) else '0';
push_ra_n_i <= '1' when ((sample_cmd(6)  = '1') and (ra_vld = '1') and (ra(34 downto 32) = "011")) else '0';
push_ra_p_d <= '1' when ((sample_cmd(5)  = '1') and (ra_vld = '1') and (ra(34 downto 32) = "110")) else '0';
push_ra_p_i <= '1' when ((sample_cmd(4)  = '1') and (ra_vld = '1') and (ra(34 downto 32) = "111")) else '0';
push_ra     <= push_ra_n_d or push_ra_n_i or push_ra_p_d or push_ra_p_i;

process (mclk,mrstn)
begin
if (mrstn = '0') then
	ra_d <= "000";
elsif (mclk'event and mclk = '1') then
	if (ra_vld = '1') then 
		ra_d <= ra(34 downto 32);
	else
		ra_d <= ra_d;
	end if;
end if;
end process;

push_rd_n_d <= '1' when ((sample_cmd(3) = '1') and (rd_vld = '1') and (ra_d = "010")) else '0';
push_rd_n_i <= '1' when ((sample_cmd(2) = '1') and (rd_vld = '1') and (ra_d = "011")) else '0';
push_rd_p_d <= '1' when ((sample_cmd(1) = '1') and (rd_vld = '1') and (ra_d = "110")) else '0';
push_rd_p_i <= '1' when ((sample_cmd(0) = '1') and (rd_vld = '1') and (ra_d = "111")) else '0';
push_rd     <= push_rd_n_d or push_rd_n_i or push_rd_p_d or push_rd_p_i;

sf_push     <= not sf_ff and (push_wa or push_wd or push_ra or push_rd);

process (push_wa,push_wd,push_ra,push_rd,rd,ra,wd,wa)
begin
case ((push_wa&push_wd&push_ra&push_rd)) is
when "0000" => sf_wdata <= "00000000000000000000000000000000";
when "0001" => sf_wdata <= rd;
when "0010" => sf_wdata <= ra(31 downto 0);
when "0100" => sf_wdata <= wd;
when "1000" => sf_wdata <= wa(31 downto 0);
when "1100" => sf_wdata <= wd;           -- data takes precedence over addr 
when others => sf_wdata <= "00000000000000000000000000000000";
end case;
end process;

-- once fifo is full won't be written to. pull data when available or read
u_samplefifo: dp_fifo
generic map (AW => 2, DW => DW) 
port map (
wrstn => mrstn,
wclk  => mclk,
rrstn => PRESETn,
rclk  => PCLK,
push  => sf_push,
pop   => sf_pop,
wdata => sf_wdata,
rdata => sample_dat,
empty => sf_fe,
full  => sf_ff
);


process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
	cstate <= INIT;
elsif (PCLK'event and PCLK = '1') then
	cstate <= nstate;
end if;
end process;

process (cstate,sf_fe,sample_reg_rd)
begin
case cstate is
when INIT   => if (sf_fe = '0') then
		nstate <= POP;
	else
		nstate <= INIT;
	end if;
when POP    => nstate <= LOAD;
when LOAD   => nstate <= HOLD;
when HOLD   => if (sf_fe = '1') then
		nstate <= INIT;
	elsif (sample_reg_rd = '1') then
		nstate <= POP;
	else
		nstate <= HOLD;
	end if;
when others => nstate <= INIT;
end case;
end process;

sf_pop        <= '1' when (cstate = POP)  else '0';
sample_reg_ld <= '1' when (cstate = LOAD) else '0';

end rtl;
