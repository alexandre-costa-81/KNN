library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity control_unit is
	port(
		-- IN
		clock			: in std_logic;
		reset			: in std_logic;	

		-- OUT
		address_exp	: out std_logic_vector (11 downto 0);
		address_knt	: out std_logic_vector (11 downto 0);
		address_result	: out std_logic_vector (11 downto 0);
		data        : out std_logic_vector (31 downto 0);
		data_knt    : out std_logic_vector (31 downto 0);
		wren			: out std_logic;
		wren_knt    : out std_logic;
		wren_result : out std_logic;
		st          : out integer;
		aux			: out integer;
		control_acc : out std_logic;
		reset_acc   : out std_logic;
		control_less_distance : out std_logic;
		reset_ld_out: out std_logic
	);
end control_unit;

architecture arq of control_unit is
-- TYPEs
type state is (initial, load_memory, load_memory_it, accumulate_reset, accumulate, accumulate_it, sqrt, sqrt_it, accumulate_load, mem_result_load, iterate, less_distance, less_distance_it, final);

-- SIGNALs
signal current_state				  : state;
signal next_state					  : state;
signal counter_clock				  : std_logic;
signal counter_memory_clear     : std_logic;
signal counter_accumulate_clear : std_logic;
signal end_loop					  : std_logic;
signal end_accumulate_loop		  : std_logic;
signal control_acc_tmp			  : std_logic;
signal control_mem_result_tmp	  : std_logic;
signal control_less_distance_tmp: std_logic;
signal example_ok					  : std_logic;
signal sqrt_ok						  : std_logic;
signal sqrt_calculing			  : std_logic;
signal reset_ld					  : std_logic;
signal less_ok					     : std_logic;
signal examples_completed		  : integer;
signal aux_tmp		  				  : integer;
signal aux_accumulate_tmp		  : integer;
signal mod_accumulate_tmp		  : integer;
signal result_accumulate_tmp    : integer;
signal less_distance_tmp		  : integer;


begin
	process (reset, clock)
	begin
		if (reset = '0') then
			current_state <= initial;
		elsif (clock'EVENT and clock = '1') then
			current_state <= next_state;
		end if;
	end process;

	-- states of state machine
	process (current_state)
	variable address_knt_tmp	: std_logic_vector (11 downto 0);
	variable address_exp_tmp	: std_logic_vector (11 downto 0);
	variable address_result_tmp	: std_logic_vector (11 downto 0);
	variable data_tmp	   : std_logic_vector (31 downto 0);
	variable data_knt_tmp: std_logic_vector (31 downto 0);
	variable wren_tmp		: std_logic;
	variable wren_knt_tmp: std_logic;
	variable wren_result_tmp: std_logic;
	
	
	begin
		case current_state is
			when initial =>
				counter_clock	<= '0';
				counter_memory_clear <= '1';
				counter_accumulate_clear<= '1';
				address_knt_tmp:= "000000000000";
				address_exp_tmp:= "000000000000";
				address_result_tmp := "000000000000";
				data_tmp   		:= "00000000000000000000000000000000";
				data_knt_tmp   := "00000000000000000000000000000000";
				wren_tmp			:= '0';
				wren_knt_tmp	:= '0';
				wren_result_tmp:= '0';
				reset_acc		<= '1';
				reset_ld       <= '1';
				st             <= 0;
				sqrt_calculing <= '0';
				next_state     <= load_memory;
				
			when load_memory =>
					counter_clock	<= '1';
					reset_acc					<= '0';
					counter_memory_clear <= '0';
					reset_ld       <= '0';
					address_knt_tmp:= std_logic_vector(to_unsigned(aux_tmp, address_knt_tmp'length));
					address_exp_tmp:= std_logic_vector(to_unsigned(aux_tmp, address_exp_tmp'length));
					address_result_tmp 	:= std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
					wren_knt_tmp	:= '0';
					wren_result_tmp:= '0';
					sqrt_calculing          <= '0';
					
					-- EXEMPLO 1
					if (address_knt_tmp = "000000000000") then
						data_tmp 		:= "00111111010111100110001101110011"; -- 0.868705
						data_knt_tmp 	:= "00111111010111110011111111011001"; -- 0.872068
						wren_knt_tmp	:= '1';
					elsif (address_knt_tmp = "000000000001") then
						-- 0.528371
						data_tmp 		:= "00111111000001110100001101010010";
						data_knt_tmp	:= "00111111000001001110011011100010"; -- 0.519148
						wren_knt_tmp	:= '1';
					elsif (address_knt_tmp = "000000000010") then
						-- 3.244254
						data_tmp 		:= "01000000010011111010000111011100";
						data_knt_tmp 	:= "01000000010011011101110111110100"; -- 3.216672
						wren_knt_tmp	:= '1';
					elsif (address_knt_tmp = "000000000011") then
						------------ 0.896013
						data_tmp 		:= "00111111011001010110000100011100";
						data_knt_tmp 	:= "00111111011010000110001100010111"; -- 0.907762
						wren_knt_tmp	:= '1';
					elsif (address_knt_tmp = "000000000100") then
						-- 0.410538
						data_tmp		   := "00111110110100100011001000001001";
						data_knt_tmp	:= "00111110110011111100100000101010"; -- 0.405824
						wren_knt_tmp	:= '1';
					elsif (address_knt_tmp = "000000000101") then
						-- 3.195505
						data_tmp 		:= "01000000010011001000001100100111";
						data_knt_tmp 	:= "01000000010010101111111110000110"; -- 3.171846
						wren_knt_tmp	:= '1';
						
					-- EXEMPLO 2
					elsif (address_exp_tmp = "000000000110") then
						-- 0.865634
						data_tmp := "00111111010111011001101000110001";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000000111") then
						-- 0.525122
						data_tmp := "00111111000001100110111001100101";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000001000") then
						-- 3.236918
						data_tmp := "01000000010011110010100110101010";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000001001") then
						-- 0.899736
						data_tmp := "00111111011001100101010100011001";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000001010") then
						-- 0.410585
						data_tmp := "00111110110100100011100000110010";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000001011") then
						-- 3.192378
						data_tmp := "01000000010011000100111111101100";
						wren_knt_tmp	:= '0';
					
					-- EXEMPLO 3
					elsif (address_exp_tmp = "000000001100") then
						-- 0.864749
						data_tmp := "00111111010111010110000000110001";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000001101") then
						-- 0.522450
						data_tmp := "00111111000001011011111101001000";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000001110") then
						-- 3.233699
						data_tmp := "01000000010011101111010011101101";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000001111") then
						-- 0.903658
						data_tmp := "00111111011001110101011000100001";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000010000") then
						-- 0.408379
						data_tmp := "00111110110100010001011100001101";
						wren_knt_tmp	:= '0';
					elsif (address_exp_tmp = "000000010001") then
						-- 3.182514
						data_tmp := "01000000010010111010111001001111";
						wren_knt_tmp	:= '0';
					end if;
					
					wren_tmp			:= '1';
					st <= 1;
				if (end_loop = '0') then
					next_state <= load_memory_it;
				else
					next_state <= accumulate_reset;
				end if;
				
			when load_memory_it =>			
				address_exp_tmp 		:= std_logic_vector(to_unsigned(aux_tmp, address_exp_tmp'length));
				address_knt_tmp 		:= std_logic_vector(to_unsigned(aux_tmp, address_knt_tmp'length));
				address_result_tmp 	:= std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				counter_clock 			<= '0';
				reset_acc				<= '0';
				reset_ld      			<= '0';
				counter_memory_clear <= '0';		
				wren_tmp					:= '0';
				wren_knt_tmp			:= '0';
				wren_result_tmp		:= '0';
				sqrt_calculing       <= '0';
				st            			<= 2;
				next_state <= load_memory;
				
			when accumulate_reset =>
				address_knt_tmp 			:= "000000000000";
				address_exp_tmp 			:= "000000000000";
				address_result_tmp 	   := std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				wren_tmp						:= '0';
				wren_knt_tmp				:= '0';
				counter_clock 				<= '0';
				reset_acc					<= '0';
				counter_memory_clear 	<= '0';
				counter_accumulate_clear<= '1';
				wren_result_tmp			:= '0';
				sqrt_calculing          <= '0';
				st <= 3;
				next_state <= accumulate_it;
				
			when accumulate =>
				address_knt_tmp 			:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 			:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	   := std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				wren_tmp						:= '0';
				wren_knt_tmp				:= '0';
				reset_acc					<= '0';
				counter_clock 				<= '1';
				counter_memory_clear 	<= '0';
				wren_result_tmp	      := '0';
				counter_accumulate_clear<= '0';
				sqrt_calculing          <= '0';
				st <= 4;
				if (control_acc_tmp = '0') then
					next_state <= accumulate_it;
				else
					next_state  <= accumulate_load;
				end if;			
				
			when accumulate_it =>
				address_knt_tmp 			:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 			:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	   := std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				wren_tmp						:= '0';
				wren_knt_tmp				:= '0';
				counter_clock 				<= '0';
				reset_acc					<= '0';
				counter_memory_clear 	<= '0';
				counter_accumulate_clear<= '0';
				wren_result_tmp         := '0';
				sqrt_calculing          <= '0';
				
				
				
				st <= 5;
				next_state <= accumulate;
				
			when accumulate_load =>
				address_knt_tmp 			:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 			:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	   := std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				sqrt_calculing          <= '0';
				reset_acc					<= '0';
				wren_tmp						:= '0';
				wren_knt_tmp				:= '0';
				wren_result_tmp:= '0';
				counter_clock 				<= '0';
				counter_memory_clear 	<= '0';
				counter_accumulate_clear<= '0';
				st <= 6;
				
				if (example_ok = '0') then
					next_state <= accumulate;				
				else
					next_state <= sqrt_it;
				end if;
				
				
			when sqrt =>
				address_knt_tmp 			:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 			:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	   := std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				wren_tmp						:= '0';
				wren_knt_tmp				:= '0';
				reset_acc					<= '0';
				sqrt_calculing          <= '1';
				counter_clock 				<= '1';
				counter_memory_clear 	<= '0';	
				wren_result_tmp:= '0';
				counter_accumulate_clear<= '0';
				st <= 7;		
		
				if (sqrt_ok = '0') then
					next_state <= sqrt_it;				
				else
					next_state <= mem_result_load;
				end if;
				
				
			when sqrt_it =>
				address_knt_tmp 			:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 			:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	   := std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				wren_tmp						:= '0';
				wren_knt_tmp				:= '0';
				reset_acc					<= '0';
				reset_ld      			   <= '0';
				wren_result_tmp			:= '0';
				sqrt_calculing          <= '1';
				counter_clock 				<= '0';
				counter_memory_clear 	<= '0';
				counter_accumulate_clear<= '0';
				st <= 8;
				next_state				<= sqrt;
				
			when mem_result_load =>
				address_knt_tmp 		:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 		:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	:= std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				wren_result_tmp		:= '1';
				sqrt_calculing 		<= '0';
				reset_acc				<= '0';
				reset_ld      			<= '0';
				st            			<= 9;	
				counter_accumulate_clear <= '0';
				next_state				<= iterate;		
			
			when iterate =>
				address_knt_tmp 		:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 		:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	:= std_logic_vector(to_unsigned(result_accumulate_tmp, address_result_tmp'length));
				wren_result_tmp		:= '0';
				sqrt_calculing 		<= '0';
				reset_acc				<= '1';
				reset_ld      			<= '0';
				st            			<= 11;	
				counter_accumulate_clear <= '0';
				
				if (end_accumulate_loop = '0') then
					next_state				<= accumulate;
				else	
					next_state				<= less_distance;
				end if;
					
			when less_distance =>
				address_knt_tmp 			:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 			:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	   := std_logic_vector(to_unsigned(less_distance_tmp, address_result_tmp'length));
				wren_tmp						:= '0';
				wren_knt_tmp				:= '0';
				reset_acc					<= '0';
				reset_ld      			   <= '0';
				sqrt_calculing          <= '0';
				counter_clock 				<= '1';
				counter_memory_clear 	<= '0';	
				wren_result_tmp:= '0';
				counter_accumulate_clear<= '0';
				st <= 12;
				
				if (less_ok = '0') then
					next_state				<= less_distance_it;
				else
					next_state				<= final;
				end if;
			
			when less_distance_it =>
				address_knt_tmp 			:= std_logic_vector(to_unsigned(mod_accumulate_tmp, address_knt_tmp'length));
				address_exp_tmp 			:= std_logic_vector(to_unsigned(aux_accumulate_tmp, address_exp_tmp'length));
				address_result_tmp 	   := std_logic_vector(to_unsigned(less_distance_tmp, address_result_tmp'length));
				wren_tmp						:= '0';
				wren_knt_tmp				:= '0';
				reset_acc					<= '0';
				reset_ld      			   <= '0';
				wren_result_tmp			:= '0';
				sqrt_calculing          <= '0';
				counter_clock 				<= '0';
				counter_memory_clear 	<= '0';
				counter_accumulate_clear<= '0';
				st <= 13;
				next_state				<= less_distance;
				
			when final =>
				address_knt_tmp	   := "000000000000";
				address_exp_tmp	   := "000000000000";
				address_result_tmp 	:= "000000000000";
				wren_tmp					:= '0';
				wren_knt_tmp			:= '0';
				wren_result_tmp		:= '0';
				reset_ld      			<= '0';
				counter_memory_clear <= '0';
				counter_accumulate_clear<= '0';
				counter_clock  		<= '0';
				st            			<= 10;
				next_state				<= final;					
		end case;
		
		address_knt <= address_knt_tmp;
		address_exp <= address_exp_tmp;
		data    	<= data_tmp;
		data_knt <= data_knt_tmp;
		wren		<= wren_tmp;
		wren_knt <= wren_knt_tmp;
		control_acc <= control_acc_tmp;
		wren_result <= wren_result_tmp;
		address_result <= address_result_tmp;
		control_less_distance <= control_less_distance_tmp;
	end process;
	
	-- LOOP -> Counter of memory management
	process (counter_clock, counter_memory_clear)
	variable counter_memory	: integer;
	begin
		if (counter_memory_clear = '1') then
			counter_memory := -1;
			end_loop <= '0';
		elsif (counter_clock'event and counter_clock = '1') then
			if (counter_memory < 18) then
				counter_memory := counter_memory + 1;		
			else
				end_loop <= '1';
			end if;
		end if;
		aux_tmp <= counter_memory;	
	end process;
	
	-- LOOP -> Counter of accumulate state
	process (counter_clock, counter_accumulate_clear)
	variable counter_accumulate			: integer;
	variable counter_accumulate_address	: integer;
	variable counter_less_distance_address: integer;
	variable number_of_data_columns		: integer; -- number of examples * number of columns in each example
	variable number_of_clocks				: integer; -- necessary clocks to finish the sub, mult and add arithmetic operations
	variable sqrt_clocks 					: integer; -- necessary clocks to finish the sqrt operation
	variable number_of_data_knt_columns : integer;
	variable mod_aux							: integer;
	variable control_acc_aux				: std_logic;
	variable repeated							: integer;
	variable sqrt_counter					: integer;
	variable counter_result_address     : integer;
	
	begin				
		if (counter_accumulate_clear = '1') then
			counter_accumulate	 		 := 0;			
			counter_accumulate_address  := 0;
			counter_less_distance_address:= 0;
			end_accumulate_loop		    <= '0';
			example_ok						 <= '0';
			mod_aux							 := 0;
			control_acc_aux		 	    := '0';
			number_of_data_columns 		 := 18;
			number_of_data_knt_columns  := 6;
			number_of_clocks				 := 30;
			sqrt_clocks				       := 15;
			sqrt_ok  						 <= '0';
			sqrt_counter					 := 0;
			less_ok							 <= '0';
			repeated							 := 1;
			counter_result_address		 := 0;
		elsif (counter_clock'event and counter_clock = '1') then
			sqrt_ok <= '0';
			if (end_accumulate_loop = '0') then
				if (sqrt_calculing = '0') then
					
					if (counter_accumulate < number_of_clocks * repeated) then
						counter_accumulate := counter_accumulate + 1;				
						control_acc_aux			:= '0';
					else
						control_acc_aux			:= '1';
						counter_accumulate := counter_accumulate + 1;
						counter_accumulate_address := counter_accumulate_address + 1;	
						mod_aux						   := counter_accumulate_address mod 6;
						
						if (mod_aux = 0) then
							example_ok <= '1';				
						end if;
						
						repeated  := repeated + 1;
						
						if (counter_accumulate_address = number_of_data_columns * repeated) then
							end_accumulate_loop <= '1';
						end if;
					end if;
				else 
					control_acc_aux			:= '0';
					if (sqrt_counter < sqrt_clocks) then						
						sqrt_counter := sqrt_counter + 1;					
					else					
						repeated := 1;
						counter_accumulate := 0;
						sqrt_ok  <= '1';	
						example_ok <= '0';
						counter_result_address := counter_result_address + 1;
					end if;
				end if;
			else
				if (counter_less_distance_address < (number_of_data_columns / number_of_data_knt_columns)) then
					counter_less_distance_address := counter_less_distance_address + 1;
				else
					less_ok <= '1';
				end if;
			end if;
			
		end if;
		aux_accumulate_tmp <= counter_accumulate_address;
		mod_accumulate_tmp <= mod_aux;
		control_acc_tmp	 <= control_acc_aux;
		examples_completed <= repeated;
		result_accumulate_tmp <= counter_result_address;
		less_distance_tmp <= counter_less_distance_address;
	end process;
	
end arq;