library ieee;
use ieee.std_logic_1164.all;

entity reg_acc is
	port (
		load	: in 	std_logic;
		d		: in 	std_logic_vector(31 downto 0);
		q		: out std_logic_vector(31 downto 0);
		reset : in std_logic
	);
end reg_acc;

architecture arc of reg_acc is
signal d_tmp : std_logic_vector(31 downto 0);
begin
	process(load)
	begin
		if (reset = '1') then
			d_tmp <= "00000000000000000000000000000000";
		elsif (load'event and load = '1') then
			d_tmp <= d;
		end if;
		
	end process;

	q <= d_tmp;
end arc;