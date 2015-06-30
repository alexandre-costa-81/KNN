library ieee;
use ieee.std_logic_1164.all;

entity reg is
	port (
		load	: in 	std_logic;
		d		: in 	std_logic_vector(31 downto 0);
		e     : in  std_logic_vector(11 downto 0);
		q		: out std_logic_vector(31 downto 0);
		e_out : out  std_logic_vector(11 downto 0); 
		reset : in std_logic
	);
end reg;

architecture arc of reg is
signal d_tmp : std_logic_vector(31 downto 0);
signal e_tmp : std_logic_vector(11 downto 0);
begin
	process(load)
	begin
		if (reset = '1') then
			d_tmp <= "01001011000110001001011001111111";
			e_tmp <= "111111111111";
		elsif (load'event and load = '1') then
			d_tmp <= d;
			e_tmp <= e;
		end if;
		
	end process;

	q <= d_tmp;
	e_out <= e_tmp;
end arc;