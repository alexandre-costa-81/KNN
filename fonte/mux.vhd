library ieee;
use ieee.std_logic_1164.all;

entity mux is
	port (
		sel: in	std_logic;
		i0	: in	std_logic_vector (31 downto 0);
		i1	: in	std_logic_vector (31 downto 0);
		o	: out	std_logic_vector (31 downto 0)
	);
end mux;

architecture arc of mux is
begin
	o <= i0 when sel = '0' else i1;
end arc;