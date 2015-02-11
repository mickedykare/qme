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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - Config/Status Registers
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/16/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.components.all;

entity config_status_reg is
port (
-- Interface Signals
rstn                     : in  std_logic;
clk                      : in  std_logic;
wen                      : in  std_logic;
waddr                    : in  std_logic_vector(31 downto 0);
wdata                    : in  std_logic_vector(31 downto 0);
ren                      : in  std_logic;
raddr                    : in  std_logic_vector(31 downto 0);
rdata                    : out std_logic_vector(31 downto 0);

-- Internal Signals
axi_rd                   : in  std_logic;
axi_wr                   : in  std_logic;
mstr_rd                  : in  std_logic;
mstr_wr                  : in  std_logic;
mst_config_wr_rd_ratio   : out std_logic_vector(2 downto 0);
slv_config_use_merr_resp : out std_logic;
sample_data              : in  std_logic_vector(31 downto 0);
sample_reg_wr            : in  std_logic;
sample_reg_rd            : out std_logic;
sample_conf_ctrl         : out std_logic_vector(15 downto 0)
);
end entity;

architecture rtl of config_status_reg is

-- Internal definitions
signal axi_stat_rd_cnt, axi_stat_wr_cnt : std_logic_vector(9 downto 0);
signal apb_stat_rd_cnt, apb_stat_wr_cnt : std_logic_vector(9 downto 0);
signal sample_reg                       : std_logic_vector(31 downto 0);
signal axi_cnt_status                   : std_logic_vector(31 downto 0);
signal axi_cnt_status_rd                : std_logic;
signal mst_cnt_status_rd                : std_logic;
signal slv_conf_rd, slv_conf_wr         : std_logic;
signal mst_conf_rd, mst_conf_wr         : std_logic;
signal sample_conf_rd, sample_conf_wr   : std_logic;
signal axi_rd_sync                      : std_logic;
signal axi_wr_sync                      : std_logic;
signal mstr_rd_sync                     : std_logic;
signal mstr_wr_sync                     : std_logic;

begin

-- Configuration and Status Registers

-- base address for APB access: 32'hC0F16000

-- Name: axi_stat
-- Description: Slave RD/WR Status
-- Address space is: C0F16000 with offset x000
-- inital value if 0
-- read to clear
-- bits [9:0]   Slave write count
-- bits [19:10] Slave read count
-- bits [31:20] unused

axi_cnt_status_rd <= '1' when ((ren = '1') and (raddr = "11000000111100010110000000000000")) else '0';
process (clk,rstn)
begin
if (rstn = '0') then
        axi_stat_rd_cnt <= "0000000000";
elsif (clk'event and clk = '1') then
	if (axi_cnt_status_rd = '1') then
       		 axi_stat_rd_cnt <= "0000000000";
	else
        	if (axi_rd_sync = '1') then
                	axi_stat_rd_cnt <= axi_stat_rd_cnt + 1;
        	else
                	axi_stat_rd_cnt <= axi_stat_rd_cnt;
		end if;
	end if;
end if;
end process;

process (clk,rstn)
begin
if (rstn = '0') then
        axi_stat_wr_cnt <= "0000000000";
elsif (clk'event and clk = '1') then
	if (axi_cnt_status_rd = '1') then
        	axi_stat_wr_cnt <= "0000000000";
	else
        	if (axi_wr_sync = '1') then
                	axi_stat_wr_cnt <= axi_stat_wr_cnt + 1;
        	else
                	axi_stat_wr_cnt <= axi_stat_wr_cnt;
		end if;
	end if;
end if;
end process;


-- Name: apb_stat
-- Description: Master RD/WR Count Status
-- Address space is: C0F16000 with offset x004
-- inital value if 0
-- Read to Clear
-- bits [9:0]   write count
-- bits [19:10] read count
-- bits [31:20] unused

mst_cnt_status_rd <= '1' when ((ren = '1') and (raddr = "11000000111100010110000000000100")) else '0';

process (clk,rstn)
begin
if (rstn = '0') then
        apb_stat_rd_cnt <= "0000000000";
elsif (clk'event and clk = '1') then
	if (mst_cnt_status_rd = '1') then
        	apb_stat_rd_cnt <= "0000000000";
	else
        	if (mstr_rd_sync = '1') then
                	apb_stat_rd_cnt <= apb_stat_rd_cnt + 1;
        	else
                	apb_stat_rd_cnt <= apb_stat_rd_cnt;
		end if;
	end if;
end if;
end process;

process (clk,rstn)
begin
if (rstn = '0') then
        apb_stat_wr_cnt <= "0000000000";
elsif (clk'event and clk = '1') then
	if (mst_cnt_status_rd = '1') then
        	apb_stat_wr_cnt <= "0000000000";
	else
        	if (mstr_wr_sync = '1') then
                	apb_stat_wr_cnt <= apb_stat_wr_cnt + 1;
        	else
                	apb_stat_wr_cnt <= apb_stat_wr_cnt;
		end if;
	end if;
end if;
end process;


-- Name: slv_config
-- Description: Slave Config  Register
-- Name: Slave Config  Register
-- Address space is: C0F16000 with offset x010
-- inital value if 0
-- Read/Write
-- bits [0]    use_merr_resp 
-- bits [31:1] unused

slv_conf_rd <= '1' when ((ren = '1') and (raddr = "11000000111100010110000000010000")) else '0';
slv_conf_wr <= '1' when ((wen = '1') and (waddr = "11000000111100010110000000010000")) else '0';

process (clk,rstn)
begin
if (rstn = '0') then
        slv_config_use_merr_resp <= '0';
elsif (clk'event and clk = '1') then
        if (slv_conf_wr = '1') then
                slv_config_use_merr_resp <= wdata(0);
        else
                slv_config_use_merr_resp <= slv_config_use_merr_resp;
	end if;
end if;
end process;


-- Name: mst_config
-- Description: Master Config Register
-- Name: Master Config Register
-- Address space is: C0F16000 with offset x020
-- inital value if 0
-- Read/Write
-- bits [2:0]   wr_rd_ratio 
-- bits [31:20] unused

mst_conf_rd <= '1' when ((ren = '1') and (raddr = "11000000111100010110000000100000")) else '0';
mst_conf_wr <= '1' when ((wen = '1') and (waddr = "11000000111100010110000000100000")) else '0';

process (clk,rstn)
begin
if (rstn = '0') then
        mst_config_wr_rd_ratio <= "000";
elsif (clk'event and clk = '1') then
        if (mst_conf_wr = '1') then
                mst_config_wr_rd_ratio <= wdata(2 downto 0);
        else
                mst_config_wr_rd_ratio <= mst_config_wr_rd_ratio;
	end if;
end if;
end process;


-- Name: sample_conf
-- Description: Sample Config Register
-- Address space is: C0F16000 with offset xB60
-- inital value if 0
-- Read/Write
-- bits [31:16]   ctrl 
-- 31  sample waddr normal data
-- 30  sample waddr normal instr
-- 29  sample waddr privileged data
-- 28  sample waddr privileged instr
-- 27  sample wdata normal data
-- 26  sample wdata normal instr
-- 25  sample wdata privileged data
-- 24  sample wdata privileged instr
-- 23  sample raddr normal data
-- 22  sample raddr normal instr
-- 21  sample raddr privileged data
-- 20  sample raddr privileged instr
-- 19  sample rdata normal data
-- 18  sample rdata normal instr
-- 17  sample rdata privileged data
-- 16  sample rdata privileged instr

sample_conf_rd <= '1' when ((ren = '1') and (raddr = "11000000111100010110101101100000")) else '0';
sample_conf_wr <= '1' when ((wen = '1') and (waddr = "11000000111100010110101101100000")) else '0';

process (clk,rstn)
begin
if (rstn = '0') then
        sample_conf_ctrl <= "0000000000000000";
elsif (clk'event and clk = '1') then
        if (sample_conf_wr = '1') then
                sample_conf_ctrl <= wdata(31 downto 16);
        else
                sample_conf_ctrl <= sample_conf_ctrl;
	end if;
end if;
end process;



-- Name: sample
-- Description: Register of samples transactions
-- Address space is: C0F16000 with offset xBAC
-- inital value if 0
-- Read Only
-- bits [31:0] reg 

sample_reg_rd <= '1' when ((ren = '1') and (raddr = "11000000111100010110101110101100")) else '0';

process (clk,rstn)
begin
if (rstn = '0') then
        sample_reg <= "00000000000000000000000000000000";
elsif (clk'event and clk = '1') then
        if (sample_reg_wr = '1') then
                sample_reg <= sample_data;
        else
                sample_reg <= sample_reg;
	end if;
end if;
end process;


-- output mux
rdata <= "00000000000000000000000000000000"                           when (ren = '0') else
         ("000000000000"&axi_stat_rd_cnt&axi_stat_wr_cnt)             when (axi_cnt_status_rd = '1') else
         ("000000000000"&apb_stat_rd_cnt&apb_stat_wr_cnt)             when (mst_cnt_status_rd = '1') else
         ("0000000000000000000000000000000"&slv_config_use_merr_resp) when (slv_conf_rd = '1')       else
         ("00000000000000000000000000000"&mst_config_wr_rd_ratio)     when (mst_conf_rd = '1')       else
         (sample_conf_ctrl&"0000000000000000")                        when (sample_conf_rd = '1')    else
         sample_reg                                                   when (sample_reg_rd = '1')     else
         "00000000000000000000000000000000";


-- syncronizers
u_axi_rd_sync: pulse_sync 
port map (
rstn => rstn,
clk  => clk,
d    => axi_rd,
p    => axi_rd_sync
);

u_axi_wr_sync: pulse_sync
port map (
rstn => rstn,
clk  => clk,
d    => axi_wr,
p    => axi_wr_sync
);

u_axi_mstr_sync: pulse_sync 
port map (
rstn => rstn,
clk  => clk,
d    => mstr_rd,
p    => mstr_rd_sync
);

u_mstr_wr_sync: pulse_sync 
port map (
rstn => rstn,
clk  => clk,
d    => mstr_wr,
p    => mstr_wr_sync
);


end rtl;
