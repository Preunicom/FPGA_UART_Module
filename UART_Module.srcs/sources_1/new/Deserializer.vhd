library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Deserializer is
  Generic(
    -- DATA_BITS + STOP_BITS + PARITY_ACTIVE <= 15 has to be fullfilled
    DATA_BITS : integer := 8;
    STOP_BITS : integer := 1;
    PARITY_ACTIVE : integer := 0; -- 0: No Parity; 1: Even or Odd Parity
    PARITY_MODE : integer := 0 -- 0: Even Parity; 1: Odd Parity
  );
  Port ( 
    clk, rst : in std_logic;
    serial_in : in std_logic;
    parallel_out : out std_logic_vector(DATA_BITS-1 downto 0);
    frame_error, parity_error : out std_logic;
    data_valid : out std_logic
  );
end Deserializer;

architecture Behavioral of Deserializer is
  signal reg : std_logic_vector(DATA_BITS+STOP_BITS+PARITY_ACTIVE downto 0);
  signal counter : integer := DATA_BITS+STOP_BITS+PARITY_ACTIVE+1;
  signal stop_bits_suffix : std_logic_vector(STOP_BITS-1 downto 0) := (others => '1');
  signal last_serial_in : std_logic := '1';
begin

  DESER: process(clk, rst)
    variable parity : std_logic;
  begin
    if rst = '1' then
      -- Clear intern data
      parity := '0';
      counter <= DATA_BITS+STOP_BITS+PARITY_ACTIVE+1;
      reg <= (others => '0');
      -- Clear outputs
      parallel_out <= (others => '0');
      data_valid <= '0';
      frame_error <= '0';
      parity_error <= '0';
    elsif rising_edge(clk) then
      -- Set default values
      --> Valid output for only one clock cycle 
      parity := '0';
      parallel_out <= (others => '0');
      data_valid <= '0';
      frame_error <= '0';
      parity_error <= '0';
      -- Shift the shift register (LSB --> shift right and put input to most significant bit of reg)
      reg <= serial_in & reg(DATA_BITS+STOP_BITS+PARITY_ACTIVE downto 1);
      -- If counter greater as the amount of UART message bits this means it was already outputted
      --> Do not count until there is a new start bit
      if counter <= DATA_BITS+STOP_BITS+PARITY_ACTIVE then
        -- Count the counter
        counter <= counter + 1;
      end if; -- These two if have to be seperated to be able to receive a start bit directly after a stop bit
      if counter > DATA_BITS+STOP_BITS+PARITY_ACTIVE and last_serial_in = '1' and serial_in = '0' then
        -- UART start bit detected (falling edge on serial in)
        --> Reset counter to 1
        counter <= 1;
      end if;
      -- If counter is bigger than UART message bits this means it was already outputted. 
      if counter = DATA_BITS+STOP_BITS+PARITY_ACTIVE then
        -- Set outputs
        parallel_out <= reg(DATA_BITS+1 downto 2); -- Last Bit not shifted yet (this clock cyle shift) and start bit as offset 
        data_valid <= '1';
        -- Calculate frame error
        if STOP_BITS = 1 then
          -- Only one Bit (serial_in) is stop bit
          if serial_in = stop_bits_suffix(0) then
            frame_error <= '0';
          else
            frame_error <= '1';
          end if;
        else
          -- More than one bit is stop bit
          -- last bits of reg are stop bits --> one offset for last received bit, and one for start bit
          if (reg(DATA_BITS+STOP_BITS+PARITY_ACTIVE downto DATA_BITS+PARITY_ACTIVE+2) & serial_in) = stop_bits_suffix then
            frame_error <= '0';
          else
            frame_error <= '1';
          end if;
        end if;
        -- Calculate parity error
        if PARITY_ACTIVE = 1 then
            -- Calculate parity incl. parity bit
            for i in 2 to DATA_BITS+2 loop
              parity := parity xor reg(i);
            end loop;
            if (parity = '1' and PARITY_MODE = 1) or (parity = '0' and PARITY_MODE = 0) then
              -- parity ok
              parity_error <= '0';
            else 
              -- parity not ok
              parity_error <= '1';
            end if;
          else  
            -- no parity
            parity_error <= '0';
          end if;
      end if;
    end if;
  end process;

  EDGE_DETECTION: process(clk, rst)
  begin
    if rst = '1' then
      last_serial_in <= '0';
    elsif rising_edge(clk) then
      last_serial_in <= serial_in;
    end if;
  end process;

end Behavioral;
