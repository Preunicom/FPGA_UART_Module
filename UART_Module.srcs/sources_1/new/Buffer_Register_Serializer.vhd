library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Buffer_Register_Serializer is
  Port ( 
    clk, rst, write_enable : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    shift_reg_read_successfully : in std_logic;
    data_out : out std_logic_vector(7 downto 0);
    full : out std_logic
    );
end Buffer_Register_Serializer;

architecture Behavioral of Buffer_Register_Serializer is
  signal data : std_logic_vector(7 downto 0) := (others => '1');
  signal full_int : std_logic := '0';
  signal last_shift_reg_data_ready : std_logic := '1';
  signal shift_reg_data_ready_change_detected : std_logic := '1';
begin
  
  BUFS: process(clk, rst)
  begin
    if rst = '1' then
      data <= (others => '1');
      data_out <= (others => '1');
      full <= '0';
      full_int <= '0';
      last_shift_reg_data_ready <= '1';
      shift_reg_data_ready_change_detected <= '1';
    elsif rising_edge(clk) then
      shift_reg_data_ready_change_detected <= shift_reg_data_ready_change_detected;
      last_shift_reg_data_ready <= shift_reg_read_successfully;
      data_out <= data;
      data <= data;
      -- Default case:
      -- current data not sent
      --> Wait for current data sent
      full <= full_int;
      full_int <= full_int;

      if (shift_reg_read_successfully = '1' and last_shift_reg_data_ready = '0') or shift_reg_data_ready_change_detected = '1' then
        shift_reg_data_ready_change_detected <= '1';
        -- current data sent
        --> Get new data
        full <= '0'; --> automatically sets write enable to false at shift reg
        full_int <= '0';
        if write_enable = '1' then
          -- new data available to load
          --> Get data if current data sent
          data <= data_in;
          data_out <= data_in;
          full_int <= '1';
          full <= '1';
          shift_reg_data_ready_change_detected <= '0';
        end if; 
      end if;
    end if;
  end process;

end Behavioral;
