library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity Deserializer is
  Port ( 
    clk, rst : in std_logic;
    serial_in : in std_logic;
    parallel_out : out std_logic_vector(7 downto 0);
    data_valid : out std_logic
  );
end Deserializer;

architecture Behavioral of Deserializer is
  signal reg : std_logic_vector(9 downto 0);
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
      reg(0) <= reg(1);
      reg(1) <= reg(2);
      reg(2) <= reg(3);
      reg(3) <= reg(4);
      reg(4) <= reg(5);
      reg(5) <= reg(6);
      reg(6) <= reg(7);
      reg(7) <= reg(8);
      reg(8) <= reg(9);
      reg(9) <= serial_in;
      if counter = 0 then
        if serial_in = '1' then
            counter <= (others => '0');
        end if;
      end if;
      if counter = 9 then
        parallel_out <= reg(9 downto 2);
        data_valid <= '1';
        counter <= (others => '0');
      end if;
    end if;
  end process;


end Behavioral;
