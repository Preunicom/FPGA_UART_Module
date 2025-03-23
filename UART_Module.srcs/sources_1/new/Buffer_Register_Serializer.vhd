library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Buffer_Register_Serializer is
  Generic(
    DATA_BITS : integer := 8
  );
  Port ( 
    clk, rst, write_enable : in std_logic;
    data_in : in std_logic_vector(DATA_BITS-1 downto 0);
    data_not_needed_anymore : in std_logic;
    data_out : out std_logic_vector(DATA_BITS-1 downto 0);
    full : out std_logic
    );
end Buffer_Register_Serializer;

architecture Behavioral of Buffer_Register_Serializer is
  signal data : std_logic_vector(DATA_BITS-1 downto 0) := (others => '1');
  signal full_int : std_logic := '0';
  signal last_data_not_needed_anymore : std_logic := '1';
  signal data_not_needed_anymore_change_detected : std_logic := '1';
begin
  
  BUFS: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        -- Clear outputs
        data_out <= (others => '1');
        full <= '0';
        -- Clear intern data
        data <= (others => '1');
        full_int <= '0';
        data_not_needed_anymore_change_detected <= '1';
      else
        -- Set default outputs
        -- Default case:
        -- current data not sent
        --> Wait for current data sent
        data_out <= data;
        full <= full_int;
        if (last_data_not_needed_anymore = '0' and data_not_needed_anymore = '1') or data_not_needed_anymore_change_detected = '1' then
          -- Remember this change
          data_not_needed_anymore_change_detected <= '1';
          -- current data sent
          --> Get new data
          full <= '0'; --> automatically sets write enable to false at shift reg
          full_int <= '0';
          if write_enable = '1' then
            -- new data available to load
            --> Get data from input
            data <= data_in;
            data_out <= data_in;
            -- Set full flag
            full_int <= '1';
            full <= '1';
            -- Forget this change
            data_not_needed_anymore_change_detected <= '0';
          end if; 
        end if;
      end if;
    end if;
  end process;

  EDGE_DETECTION: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        last_data_not_needed_anymore <= '1';
      else
       last_data_not_needed_anymore <= data_not_needed_anymore;
      end if;
    end if;
  end process;

end Behavioral;
