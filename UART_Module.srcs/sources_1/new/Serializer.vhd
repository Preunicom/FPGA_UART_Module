library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Serializer is
  Generic(
    -- DATA_BITS + STOP_BITS <= 15 has to be fullfilled
    DATA_BITS : integer := 8;
    STOP_BITS : integer := 1
  );
  Port ( 
    clk, rst, write_enable : in std_logic;
    parallel_in : in std_logic_vector(DATA_BITS-1 downto 0);
    serial_out : out std_logic;
    data_saved_to_send : out std_logic
  );
end Serializer;

architecture Behavioral of Serializer is
  signal reg : std_logic_vector(DATA_BITS+STOP_BITS downto 0); -- data + stop + start bits
  signal counter : std_logic_vector(3 downto 0);
  signal stop_bits_suffix : std_logic_vector(STOP_BITS-1 downto 0) := (others => '1');
begin

  SER: process(clk, rst)
  begin
    if rst = '1' then
      reg <= (others => '1');
      counter <= (others => '0');
      serial_out <= '1';
      data_saved_to_send <= '1';
    elsif rising_edge(clk) then
      data_saved_to_send <= '0';
      counter <= counter + 1;
      serial_out <= reg(0);
      reg <= '1' & reg(DATA_BITS+STOP_BITS downto 1);
      if counter = DATA_BITS+STOP_BITS then
        if write_enable = '1' then
          reg <= stop_bits_suffix & parallel_in & '0';
          counter <= (others => '0');
          data_saved_to_send <= '1';
        else
          counter <= "1001";
        end if;
      end if;
    end if;
  end process;

end Behavioral;
