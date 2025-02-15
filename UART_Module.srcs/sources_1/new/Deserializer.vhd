library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity Deserializer is
  Generic(
    -- DATA_BITS + STOP_BITS <= 15 has to be fullfilled
    DATA_BITS : integer := 8;
    STOP_BITS : integer := 1
  );
  Port ( 
    clk, rst : in std_logic;
    serial_in : in std_logic;
    parallel_out : out std_logic_vector(DATA_BITS-1 downto 0);
    data_valid : out std_logic
  );
end Deserializer;

architecture Behavioral of Deserializer is
  signal reg : std_logic_vector(DATA_BITS+STOP_BITS downto 0);
  signal counter : std_logic_vector(3 downto 0) := "0000";
begin

  DESER: process(clk, rst)
  begin
    if rst = '1' then
      reg <= (others => '0');
      counter <= (others => '0');
      parallel_out <= (others => '0');
      data_valid <= '0';
    elsif rising_edge(clk) then
      parallel_out <= (others => '0');
      data_valid <= '0';
      counter <= counter + 1;
      reg <= serial_in & reg(DATA_BITS+STOP_BITS downto 1);
      if counter = 0 then
        if serial_in = '1' then
            counter <= (others => '0');
        end if;
      end if;
      if counter = DATA_BITS+STOP_BITS then
        parallel_out <= reg(DATA_BITS+1 downto 2); -- Last Bit not shifted yet (this clock cyle shift) and start bit as offset 
        data_valid <= '1';
        counter <= (others => '0');
      end if;
    end if;
  end process;


end Behavioral;
