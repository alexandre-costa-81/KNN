library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.example_type.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity knncalc is
   port (
      -- IN
      clock                      : in  std_logic;
      reset                      : in  std_logic;
      UART_RXD                   : in  std_logic;
      KEY                        : in  std_logic_vector(3 downto 0);

      -- OUT
      memory                     : out std_logic_vector (31 downto 0);
      memory_knt                 : out std_logic_vector (31 downto 0);
      memory_result              : out std_logic_vector (31 downto 0);
      state                      : out integer;
      UART_TXD                   : out std_logic;

      --sub_result                  : out std_logic_vector (31 downto 0);
      --add_result                  : out std_logic_vector (31 downto 0);
      --exp_result                  : out std_logic_vector (31 downto 0);
      --address_knt                : out std_logic_vector (11 downto 0);
      --address_exp                : out std_logic_vector (11 downto 0);
      --address_result             : out std_logic_vector (11 downto 0);

      --less_distance_out          : out std_logic_vector (31 downto 0);
      --acc_out                    : out std_logic_vector (31 downto 0);
      --dataa_out                  : out std_logic_vector (31 downto 0);
      --datab_out                  : out std_logic_vector (31 downto 0);
      --pre_add_out                : out std_logic_vector (31 downto 0);
      --control_acc_out            : out std_logic;
      --reset_out                  : out std_logic;
      --sqrt_result                : out std_logic_vector (31 downto 0);
      --control_less_distance_out  : out std_logic;
      --reset_ld_out               : out std_logic;
      end_knn_out                : out std_logic;
      alb_out                    : out std_logic
   );
end knncalc;

architecture arq of knncalc is
   signal mem_exp_control_address    : std_logic_vector (11 downto 0);
   signal mem_knt_control_address    : integer;
   signal mem_result_control_address : std_logic_vector (11 downto 0);
   signal sqrt_mem_result            : std_logic_vector (31 downto 0);
   signal exp_add                    : std_logic_vector (31 downto 0);
   signal acc_mem                    : std_logic_vector (31 downto 0);
   signal control_mem_data           : std_logic_vector (31 downto 0);
   signal add_acc                    : std_logic_vector (31 downto 0);
   signal data_knt                   : std_logic_vector (31 downto 0);
   signal mem_knt_sub_data           : std_logic_vector (31 downto 0);
   signal mem_exp_sub_data           : std_logic_vector (31 downto 0);
   signal result_sub                 : std_logic_vector (31 downto 0);
   signal result_pre_add             : std_logic_vector (31 downto 0);
   signal sqrt_mem                   : std_logic_vector (31 downto 0);
   signal mem_result_data            : std_logic_vector (31 downto 0);
   signal control_acc                : std_logic;
   signal mem_wren_control           : std_logic;
   signal wren_knt                   : std_logic;
   signal wren_result                : std_logic;
   signal reset_acc                  : std_logic;
   signal control_less_distance      : std_logic;
   signal reset_ld                   : std_logic;
   signal alb_signal                 : std_logic;
   signal ld_out                     : std_logic_vector (31 downto 0);
   signal end_knn                    : std_logic;

   signal LEDR                       : STD_LOGIC_VECTOR(17 DOWNTO 0);
   signal LEDG                       : STD_LOGIC_VECTOR(8 DOWNTO 0);
   signal knt_address                : integer;
   signal DATA_OUT                   : example75f;

   -- memory
   -- wren = '0' read only
   -- wren = '1' write only
   component ram is
      port (
         address  : in  std_logic_vector (11 downto 0);
         clock    : in  std_logic ;
         data     : in  std_logic_vector (31 downto 0);
         wren     : in  std_logic ;
         q        : out std_logic_vector (31 downto 0)
      );
   end component;

   -- mux 2x1
   component mux is
      port (
         sel: in  std_logic;
         i0 : in  std_logic_vector (31 downto 0);
         i1 : in  std_logic_vector (31 downto 0);
         o  : out std_logic_vector (31 downto 0)
      );
   end component;

   -- adder and subtrator
   component fp_add_sub is
      port (
         add_sub  : in  std_logic;
         clock    : in  std_logic;
         dataa    : in  std_logic_vector (31 downto 0);
         datab    : in  std_logic_vector (31 downto 0);
         result   : out std_logic_vector (31 downto 0)
      );
   end component;

   -- multipler
   component fp_mult is
      port (
         clock    : in  std_logic ;
         dataa    : in  std_logic_vector (31 downto 0);
         datab    : in  std_logic_vector (31 downto 0);
         result   : out std_logic_vector (31 downto 0)
      );
   end component;

   component control_unit is
      port(
         -- IN
         clock                : in  std_logic;
         reset                : in  std_logic;
         alb                  : in  std_logic;

         -- OUT
         address_exp          : out std_logic_vector (11 downto 0);
         address_knt          : out integer;
         address_result       : out std_logic_vector (11 downto 0);
         data                 : out std_logic_vector (31 downto 0);
         wren                 : out std_logic;
         st                   : out integer;
         wren_knt             : out std_logic;
         wren_result          : out std_logic;
         data_knt             : out std_logic_vector (31 downto 0);
         control_acc          : out std_logic;
         reset_acc            : out std_logic;
         control_less_distance: out std_logic;
         reset_ld_out         : out std_logic;
         end_knn              : out std_logic
      );
   end component;

   component reg is
      port (
         load  : in  std_logic;
         reset : in  std_logic;
         d     : in  std_logic_vector(31 downto 0);
         q     : out std_logic_vector(31 downto 0)
      );
   end component;

   component reg_acc is
      port (
         load  : in  std_logic;
         reset : in  std_logic;
         d     : in  std_logic_vector(31 downto 0);
         q     : out std_logic_vector(31 downto 0)
      );
   end component;

   component fp_sqrt is
      port
      (
         clock    : in  STD_LOGIC ;
         data     : in  STD_LOGIC_VECTOR (31 DOWNTO 0);
         result   : out STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
   end component;

   component fp_compare is
      port
      (
         clock    : IN STD_LOGIC ;
         dataa    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
         alb      : OUT STD_LOGIC 
      );
   end component;

   component test_receive is
   port(
      CLOCK_50: in std_logic;
      UART_TXD: OUT STD_LOGIC;
      UART_RXD: IN STD_LOGIC;
      KEY: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      LEDR: OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
      LEDG: OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
      DATA_OUT : OUT example75f
   );
   end component;

   begin
      receiver       : test_receive port map(CLOCK_50 => clock, UART_TXD => UART_TXD, UART_RXD => UART_RXD, KEY => KEY, LEDR => LEDR, LEDG => LEDG, DATA_OUT => DATA_OUT);
      mem_read       : ram port map(address => mem_exp_control_address, clock => clock, data => control_mem_data, wren => mem_wren_control, q => mem_exp_sub_data);
      sub            : fp_add_sub port map(add_sub => '0', clock => clock, dataa => mem_exp_sub_data, datab => DATA_OUT(mem_knt_control_address), result => result_sub);		
      pre_add        : fp_add_sub port map(add_sub => '1', clock => clock, dataa => "01000001001000000000000000000000", datab => result_sub, result => result_pre_add);
      exp            : fp_mult port map (clock => clock, dataa => result_pre_add, datab => result_pre_add, result => exp_add);
      add            : fp_add_sub port map(add_sub => '1', clock => clock, dataa => exp_add, datab => acc_mem, result => add_acc);
      acc            : reg_acc port map(load => control_acc, d => add_acc, q => acc_mem, reset => reset_acc);
      sqrt           : fp_sqrt port map(clock => clock, data => acc_mem, result => sqrt_mem);
      control        : control_unit port map(end_knn => end_knn, alb => alb_signal, control_less_distance => control_less_distance, control_acc => control_acc, wren_knt => wren_knt, data_knt => data_knt, st => state, clock => clock, reset => reset, address_exp => mem_exp_control_address, address_knt => mem_knt_control_address, data => control_mem_data, wren => mem_wren_control, address_result => mem_result_control_address, wren_result => wren_result, reset_acc => reset_acc, reset_ld_out => reset_ld);
      --mem_result      : ram  port map(address => mem_result_control_address, clock => clock, data => sqrt_mem, wren => wren_result, q => mem_result_data);
      less_distance  : reg port map(load => control_less_distance, d => sqrt_mem, q => ld_out, reset => reset_ld);
      compare        : fp_compare port map(clock => clock, dataa => sqrt_mem, datab => ld_out, alb => alb_signal);

      memory                     <= mem_exp_sub_data;
      --memory_knt                  <= mem_knt_sub_data;
      --address_exp                 <= mem_exp_control_address;
      --address_knt                 <= mem_knt_control_address;
      --address_result              <= mem_result_control_address;
      --acc_out                     <= acc_mem;
      --control_acc_out             <= control_acc;
      --sub_result                  <= result_sub;
      --add_result                  <= add_acc;
      --exp_result                  <= exp_add;
      --dataa_out                   <= mem_exp_sub_data;
      --datab_out                   <= mem_knt_sub_data;
      --pre_add_out                 <= result_pre_add;
      --memory_result               <= mem_result_data;
      --sqrt_result                 <= sqrt_mem;
      --reset_out                   <= reset_acc;
      --control_less_distance_out   <= control_less_distance;
      --less_distance_out           <= ld_out;
      --reset_ld_out                <= reset_ld;
      --end_knn_out                 <= end_knn;
      --alb_out                     <= alb_signal;
end arq;
