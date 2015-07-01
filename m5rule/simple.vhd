library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;
use ieee.float_pkg.all;
use work.example_type.all;
--------------------------------------

entity simple is

port(
	CLOCK_50: in std_logic;
	UART_TXD: OUT STD_LOGIC;
	UART_RXD: IN STD_LOGIC;
	KEY: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	LEDR: OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
	LEDG: OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
);
end simple;

architecture simple_arch of simple is
signal temp_x: std_logic_vector(31 downto 0);
signal temp_r: float32;
SIGNAL TX_DATA: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TX_START: STD_LOGIC := '0';
SIGNAL TX_BUSY: STD_LOGIC;
SIGNAL RX_DATA: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL RX_BUSY: STD_LOGIC;
SIGNAL COUNT1S: INTEGER RANGE 0 TO 102:=0;
COMPONENT TX
PORT(
CLK: IN STD_LOGIC;
START: IN STD_LOGIC;
BUSY: OUT STD_LOGIC;
DATA: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
TX_LINE: OUT STD_LOGIC
);
END COMPONENT TX;
COMPONENT RX
PORT(
CLK: IN STD_LOGIC;
RX_LINE: IN STD_LOGIC;
DATA: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
BUSY: OUT STD_LOGIC
);
END COMPONENT RX;
BEGIN
	C1: TX PORT MAP(CLOCK_50, TX_START, TX_BUSY, TX_DATA, UART_TXD);
	C2: RX PORT MAP(CLOCK_50, UART_RXD, RX_DATA, RX_BUSY);  
	TX_START <= '0';
	PROCESS
	BEGIN	
		WAIT UNTIL RX_BUSY'EVENT AND RX_BUSY='0';	
		IF(RX_DATA = "11111111" AND COUNT1S = 0) THEN
			COUNT1S <= COUNT1S + 1;
		ELSIF(RX_DATA = "11111111" AND COUNT1S = 1) THEN
			COUNT1S <= COUNT1S + 1;
		ELSIF(RX_DATA = "11111111" AND COUNT1S = 2) THEN
			COUNT1S <= COUNT1S + 1;
		ELSIF(RX_DATA = "11111111" AND COUNT1S = 3) THEN
			COUNT1S <= COUNT1S + 1;
		ELSIF(COUNT1S = 4) THEN
--			LEDR(7 DOWNTO 0) <= RX_DATA;
			temp_x(31 DOWNTO 24) <= RX_DATA;
			COUNT1S <= COUNT1S + 1;
		ELSIF(COUNT1S = 5) THEN
			temp_x(23 DOWNTO 16) <= RX_DATA;
			COUNT1S <= COUNT1S + 1;
		ELSIF(COUNT1S = 6) THEN
			temp_x(15 DOWNTO 8) <= RX_DATA;
			COUNT1S <= COUNT1S + 1;
		ELSIF(COUNT1S = 7) THEN
			temp_x(7 DOWNTO 0) <= RX_DATA;
			COUNT1S <= COUNT1S + 1;
--			LEDR(7 DOWNTO 0) <= temp_x(31 DOWNTO 24);
			if(to_float(temp_x) <= to_float(0.021)) then
				temp_r <= to_float(0.1811) * to_float(temp_x) + to_float(0.0271);
			else
				temp_r <= to_float(1.0);
			end if;
			
			if(temp_r < to_float(0.5)) then
				LEDR(17 DOWNTO 0) <= (others => '1');
				LEDG(8 DOWNTO 0) <= (others => '0');
			else
				LEDR(17 DOWNTO 0) <= (others => '0');
				LEDG(8 DOWNTO 0) <= (others => '1');
			end if;
			COUNT1S <= 0;
		ELSE
			COUNT1S <= 0;
		END IF;
--		LEDR(7 DOWNTO 0) <= RX_DATA;
		--LEDG(7 DOWNTO 0) <= STD_LOGIC_VECTOR(TO_UNSIGNED(COUNT1S,8));
	END PROCESS;
end simple_arch;