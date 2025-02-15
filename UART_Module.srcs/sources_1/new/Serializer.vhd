library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Serializer is
      Port ( 
        clk, rst, write_enable : in std_logic;
        parallel_in : in std_logic_vector(7 downto 0);
        serial_out : out std_logic;
        read_successfully : out std_logic
      );
end Serializer;

architecture Behavioral of Serializer is
  signal reg : std_logic_vector(9 downto 0);
  signal counter : std_logic_vector(3 downto 0);
begin

  SER: process(clk, rst)
  begin
    if rst = '1' then
      reg <= (others => '1');
      counter <= (others => '0');
      serial_out <= '1';
      read_successfully <= '1';
    elsif rising_edge(clk) then
      read_successfully <= '0';
      counter <= counter + 1;
      serial_out <= reg(0);
      reg(0) <= reg(1);
      reg(1) <= reg(2);
      reg(2) <= reg(3);
      reg(3) <= reg(4);
      reg(4) <= reg(5);
      reg(5) <= reg(6);
      reg(6) <= reg(7);
      reg(7) <= reg(8);
      reg(8) <= reg(9);
      reg(9) <= '1';
      if counter = 9 then
        if write_enable = '1' then
          reg <= '1' & parallel_in & '0';
          counter <= (others => '0');
          read_successfully <= '1';
        else
          counter <= "1001";
        end if;
      end if;
    end if;
  end process;

end Behavioral;
