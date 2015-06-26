library ieee;
use ieee.std_logic_1164.all;
package example_type is
    type example_float32 is array(0 to 74) of STD_LOGIC_VECTOR(31 DOWNTO 0);
end package example_type;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;
use work.example_type.all;
--------------------------------------

entity test_receive is

port(
	CLOCK_50: in std_logic;
	UART_TXD: OUT STD_LOGIC;
	UART_RXD: IN STD_LOGIC;
	KEY: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	LEDR: OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
	LEDG: OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
);
end test_receive;

architecture KNN_arch of test_receive is
type example75f is array(0 to 74) of std_logic_vector(31 downto 0);
type examples is array(0 to 1) of example75f;
signal x: example75f;
signal exemplos: examples;
signal starting: std_logic := '1';
SIGNAL TX_DATA: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TX_START: STD_LOGIC := '0';
SIGNAL TX_BUSY: STD_LOGIC;
SIGNAL RX_DATA: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL RX_BUSY: STD_LOGIC;
SIGNAL WORD_INDEX: INTEGER RANGE 0 TO 3:=0;
SIGNAL DATA0: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA1: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA2: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA3: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL COLUMN: INTEGER RANGE 0 TO 74:=0;
SIGNAL receiving: integer range 0 to 3 := 0;
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
	PROCESS(CLOCK_50)
	variable y: std_logic;
	variable etapa: integer range 0 to 10:=0;
	variable countc: integer range 0 to 77:=0;
	variable countr: integer range 0 to 77:=0;
	variable count_wait: integer range 0 to 5000002:=0;
	BEGIN	
		IF(CLOCK_50'EVENT AND CLOCK_50='1') THEN
			IF(receiving=0 AND TX_BUSY='0') THEN
				TX_DATA <= "11111111";
				TX_START <= '1';
				receiving <= 1;
			ELSE
				TX_START <= '0';
			END IF;
			IF(receiving = 1 AND RX_BUSY='0') THEN
				IF(WORD_INDEX=0) THEN
					DATA0 <= RX_DATA;
					WORD_INDEX <= WORD_INDEX+1;
				ELSIF(WORD_INDEX=1) THEN
					DATA1 <= RX_DATA;
					WORD_INDEX <= WORD_INDEX+1;
				ELSIF(WORD_INDEX=2) THEN
					DATA2 <= RX_DATA;
					WORD_INDEX <= WORD_INDEX+1;
				ELSIF(WORD_INDEX=3) THEN
					DATA3 <= RX_DATA;
					x(COLUMN) <= DATA0 & DATA1 & DATA2 & DATA3;
					COLUMN <= COLUMN + 1;
					WORD_INDEX <= 0;
					IF(COLUMN = 75) THEN --75, 0 to 74
						COLUMN <= 0;
						--LEDR(17 DOWNTO 0) <= x(2)(17 DOWNTO 0);
						receiving <= 2;
					END IF;
				END IF;
			end if;
		END IF;
	END PROCESS;
end KNN_arch;