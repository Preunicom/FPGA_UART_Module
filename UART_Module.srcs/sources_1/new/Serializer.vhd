library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Serializer is
  Generic(
    -- DATA_BITS + STOP_BITS + PARITY_ACTIVE <= 15 has to be fullfilled
    DATA_BITS : integer := 8;
    STOP_BITS : integer := 1;
    PARITY_ACTIVE : integer := 0; -- 0: No Parity; 1: Even or Odd Parity
    PARITY_MODE : integer := 0 -- 0: Even Parity; 1: Odd Parity
  );
  Port ( 
    clk, rst, write_enable : in std_logic;
    parallel_in : in std_logic_vector(DATA_BITS-1 downto 0);
    serial_out : out std_logic;
    buffer_data_saved : out std_logic
  );
end Serializer;

architecture Behavioral of Serializer is
  signal reg : std_logic_vector(DATA_BITS+STOP_BITS+PARITY_ACTIVE downto 0) := (others => '1'); -- data + stop + start + parity bits
  signal counter : std_logic_vector(3 downto 0) := (others => '1');
  signal stop_bits_suffix : std_logic_vector(STOP_BITS-1 downto 0) := (others => '1');
begin

  SER: process(clk, rst)
    variable parity : std_logic; -- 0: Even number of ones; 1: Odd number of ones
  begin
    if rst = '1' then
      -- Clear intern data
      parity := '0';
      reg <= (others => '1');
      counter <= (others => '1');
      -- Clear outputs
      serial_out <= '1';
      buffer_data_saved <= '0';
    elsif rising_edge(clk) then
      -- Set default values
      --> Valid output for only one clock cycle 
      buffer_data_saved <= '0';
      counter <= counter + 1;
      parity := '0';
      -- Shift the shift register (LSB --> shift left and put 1 to highest bit)
      reg <= '1' & reg(DATA_BITS+STOP_BITS+PARITY_ACTIVE downto 1);
      -- Set output to least significant bit of reg
      serial_out <= reg(0);
      if counter >= DATA_BITS+STOP_BITS+PARITY_ACTIVE then
        -- reg empty (Shifted last bit out)
        if write_enable = '1' then
          -- new data given
          if PARITY_ACTIVE = 1 then
            -- Calculate parity
            for i in 0 to DATA_BITS-1 loop
              parity := parity xor parallel_in(i);
            end loop;
            -- Add parity bit
            if (parity = '1' and PARITY_MODE = 1) or (parity = '0' and PARITY_MODE = 0) then
              -- Add 0 as parity bit
              reg <= stop_bits_suffix & '0' & parallel_in & '0';
            else 
              -- Add 1 as parity bit
              reg <= stop_bits_suffix & '1' & parallel_in & '0';
            end if;
          else  
            -- Add no parity bit
            reg <= stop_bits_suffix & parallel_in & '0';
          end if;
          -- reset counter
          counter <= (others => '0');
          -- set buffer data saved output
          buffer_data_saved <= '1';
        else
          --no new data given
          -- Set counter to max value
          counter <= (others => '1');
        end if;
      end if;
    end if;
  end process;

end Behavioral;
