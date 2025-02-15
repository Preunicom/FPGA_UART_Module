library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity Buffer_Register_Deserializer is
  Port ( 
    clk, rst : in STD_LOGIC;
    parallel_in : in std_logic_vector(7 downto 0);
    write_en : in std_logic;
    parallel_out : out std_logic_vector(7 downto 0);
    new_data : out std_logic
  );
end Buffer_Register_Deserializer;

architecture Behavioral of Buffer_Register_Deserializer is
  signal data : std_logic_vector(7 downto 0);
begin

  BUFDES: process(clk, rst)
  begin
    if rst = '1' then
      data <= (others => '0');
      parallel_out <= (others => '0');
      new_data <= '0';
    elsif rising_edge(clk) then
      new_data <= '0';
      parallel_out <= data;
      if write_en = '1' then
        new_data <= '1';
        data <= parallel_in;
        parallel_out <= parallel_in;
      end if;
    end if;
  end process;

end Behavioral;