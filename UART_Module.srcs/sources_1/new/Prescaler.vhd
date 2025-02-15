library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Prescaler is
  Generic(
    IN_FREQ_HZ : integer := 12000000;
    OUT_FREQ_HZ : integer := 9600
  );
  Port ( 
    clk, rst : in STD_LOGIC;
    clk_prescaled : out STD_LOGIC
  );
end Prescaler;

architecture Behavioral of Prescaler is
  signal counter : integer;
  signal clk_prescaled_intern : std_logic;
begin

  PRESCALER: process(clk)
  begin
      if rising_edge(clk) then
          if rst = '1' then
            clk_prescaled_intern <= '1';
            clk_prescaled <= '1';
            counter <= 0;
          else 
            counter <= counter + 1;
            clk_prescaled_intern <= clk_prescaled_intern;
            clk_prescaled <= clk_prescaled_intern;
            if counter >= ((IN_FREQ_HZ + OUT_FREQ_HZ) / (2 * OUT_FREQ_HZ)) then
              clk_prescaled_intern <= clk_prescaled_intern nand clk_prescaled_intern;
              clk_prescaled <= clk_prescaled_intern nand clk_prescaled_intern;
              counter <= 0;
            end if;
          end if;
      end if;
  end process;

end Behavioral;