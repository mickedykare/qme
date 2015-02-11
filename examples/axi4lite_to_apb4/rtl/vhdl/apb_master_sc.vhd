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
-- DESCRIPTION   : AXI4Lite to APB4 Bridge - APB4 Master Interface
--                 Single clock bridge - read has priority when both
-- AUTHOR        : Mark Eslinger 
-- Last Modified : 1/14/15
-- 
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity apb_master_sc is
port (
-- APB4 Interface Signals
PCLK    : in  std_logic;
PRESETn : in  std_logic;
PSELx   : out std_logic;
PENABLE : out std_logic;
PADDR   : out std_logic_vector(31 downto 0);
PPROT   : out std_logic_vector(2 downto 0);
PWRITE  : out std_logic;
PWDATA  : out std_logic_vector(31 downto 0);
PSTRB   : out std_logic_vector(3 downto 0); -- drive low for reads
PREADY  : in  std_logic;
PRDATA  : in  std_logic_vector(31 downto 0);
PSLVERR : in  std_logic; -- can tie 0 if not used

--internal Signals
use_1clk     : in  std_logic;
waddr_prot   : in  std_logic_vector(34 downto 0);
waddr_wen    : in  std_logic;
waddr_ready  : out std_logic;
wdata_strb   : in  std_logic_vector(35 downto 0);
wdata_wen    : in  std_logic;
wdata_ready  : out std_logic;
raddr_prot   : in  std_logic_vector(34 downto 0);
raddr_wen    : in  std_logic;
raddr_ready  : out std_logic;
rdata_slverr : out std_logic_vector(32 downto 0);
rdata_ready  : in  std_logic;
rdata_valid  : out std_logic;
bready       : in  std_logic;
bvalid       : out std_logic;
bresp        : out std_logic
);
end entity;

architecture rtl of apb_master_sc is

-- signal definition 
type state is (IDLE,WSETUP,WACTIVE,RSETUP, RACTIVE);
signal cstate, nstate : state;
signal waddr_prot_r   : std_logic_vector(34 downto 0);
signal wdata_strb_r   : std_logic_vector(35 downto 0);
signal raddr_prot_r   : std_logic_vector(34 downto 0);
signal wa_active      : std_logic;
signal wd_active      : std_logic;
signal ra_active      : std_logic;
signal b_active       : std_logic;
signal apb_wr         : std_logic;
signal apb_rd         : std_logic;

begin

-- design code 

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
	waddr_prot_r <= "00000000000000000000000000000000000"; 
elsif (PCLK'event and PCLK = '1') then
	if ((waddr_wen = '1') and (use_1clk = '1')) then
		waddr_prot_r <= waddr_prot;
	else
		waddr_prot_r <= waddr_prot_r;
	end if;
end if;
end process;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        wdata_strb_r <= "000000000000000000000000000000000000";
elsif (PCLK'event and PCLK = '1') then
        if ((wdata_wen = '1') and (use_1clk = '1')) then
                wdata_strb_r <= wdata_strb;
        else
                wdata_strb_r <= wdata_strb_r;
	end if;
end if;
end process;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        bresp <= '0';
elsif (PCLK'event and PCLK = '1') then
        if ((apb_wr = '1') and (use_1clk = '1')) then
                bresp <= PSLVERR;
        else
                bresp <= bresp;
	end if;
end if;
end process;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        raddr_prot_r <= "00000000000000000000000000000000000";
elsif (PCLK'event and PCLK = '1') then
        if ((raddr_wen = '1') and (use_1clk = '1')) then
                raddr_prot_r <= raddr_prot;
        else
                raddr_prot_r <= raddr_prot_r;
	end if;
end if;
end process;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        rdata_slverr <= "000000000000000000000000000000000";
elsif (PCLK'event and PCLK = '1') then
        if ((apb_rd = '1') and (use_1clk = '1')) then
                rdata_slverr <= (PSLVERR&PRDATA);
	elsif (rdata_ready = '1') then
		rdata_slverr <= "000000000000000000000000000000000";
        else
                rdata_slverr <= rdata_slverr;
	end if;
end if;
end process;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        wa_active <= '0';
elsif (PCLK'event and PCLK = '1') then
        if ((apb_wr = '1') and (waddr_wen = '0')) then
                wa_active <= '0';
	elsif ((waddr_wen = '1') and (use_1clk = '1')) then
		wa_active <= '1';
        else
		wa_active <= wa_active;
	end if;
end if;
end process;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        wd_active <= '0';
elsif (PCLK'event and PCLK = '1') then
        if ((apb_wr = '1') and (wdata_wen = '0')) then
                wd_active <= '0';
	elsif ((wdata_wen = '1') and (use_1clk = '1')) then
		wd_active <= '1';
        else
                wd_active <= wd_active;
	end if;
end if;
end process;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        b_active <= '0';
elsif (PCLK'event and PCLK = '1') then
        if ((apb_wr = '1') and (bready = '1')) then
                b_active <= '0';
	elsif ((bready = '1') and (b_active = '1')) then
		b_active <= '0';
        elsif ((apb_wr = '1') and (bready = '0') and (use_1clk = '1')) then
                b_active <= '1';
        else
                b_active <= b_active;
	end if;
end if;
end process;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        ra_active <= '0';
elsif (PCLK'event and PCLK = '1') then
        if ((apb_rd = '1') and (raddr_wen = '0')) then
                ra_active <= '0';
	elsif ((raddr_wen = '1') and (use_1clk = '1')) then
		ra_active <= '1';
        else
                ra_active <= ra_active;
	end if;
end if;
end process;

waddr_ready <= not wa_active or (wa_active and apb_wr);
wdata_ready <= not wd_active or (wd_active and apb_wr and bready);
bvalid      <=     b_active  or (bready    and apb_wr);
raddr_ready <= not ra_active or (ra_active and apb_rd);

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
        rdata_valid <= '0';
elsif (PCLK'event and PCLK = '1') then
	if ((apb_rd = '1') and (use_1clk = '1')) then
		rdata_valid <= '1';
	elsif (rdata_ready = '1') then
		rdata_valid <= '0';
        else
                rdata_valid <= rdata_valid;
	end if;
end if;
end process;

PSELx   <= '1' when (cstate /= IDLE) else '0';
PWRITE  <= '1' when (cstate = WSETUP)  or (cstate = WACTIVE) else '0';
PENABLE <= '1' when (cstate = WACTIVE) or (cstate = RACTIVE) else '0';
PPROT   <= waddr_prot_r(34 downto 32) when (PWRITE = '1') else raddr_prot_r(34 downto 32);
PADDR   <= waddr_prot_r(31 downto 0)  when (PWRITE = '1') else raddr_prot_r(31 downto 0);
PSTRB   <= wdata_strb_r(35 downto 32) when (PWRITE = '1') else "0000";
PWDATA  <= wdata_strb_r(31 downto 0);

apb_rd  <= PSELx and PENABLE and not PWRITE and PREADY;
apb_wr  <= PSELx and PENABLE and     PWRITE and PREADY;

process (PCLK,PRESETn)
begin
if (PRESETn = '0') then
	cstate <= IDLE;
elsif (PCLK'event and PCLK = '1') then
	cstate <= nstate;
end if;
end process;

process (cstate,PREADY,use_1clk,raddr_wen,waddr_wen,wdata_wen,wa_active,wd_active,ra_active)
begin
case cstate is
when IDLE   => if ((raddr_wen = '1') and (use_1clk = '1')) then
		nstate <= RSETUP;
	elsif ((waddr_wen = '1') and (wdata_wen = '1') and (use_1clk = '1')) then
		nstate <= WSETUP;
	elsif ((waddr_wen = '1') and (wd_active = '1') and (use_1clk = '1')) then
		nstate <= WSETUP;
	elsif ((wdata_wen = '1') and (wa_active = '1') and (use_1clk = '1')) then
		nstate <= WSETUP;
	else
		nstate <= IDLE; 
	end if;
when WSETUP  => nstate <= WACTIVE;
when WACTIVE => if (PREADY = '0') then
		nstate <= WACTIVE;
	 elsif (ra_active = '1') then
		nstate <= RSETUP;
         elsif ((wa_active = '1') and (wd_active = '1') and (waddr_wen = '1') and (wdata_wen = '1')) then
		nstate <= WSETUP;
         else
		nstate <= IDLE;
	end if;
when RSETUP  => nstate <= RACTIVE;
when RACTIVE => if (PREADY = '0') then
                nstate <= RACTIVE;
         elsif ((wa_active = '1') and (wd_active = '1')) then
                nstate <= WSETUP;
         elsif ((ra_active = '1') and (raddr_wen = '1')) then
                nstate <= RSETUP;
         else
                nstate <= IDLE;
	end if;
when others => nstate <= IDLE;
end case;
end process;


end rtl;
