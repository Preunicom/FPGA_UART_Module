library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.STD_LOGIC_UNSIGNED.all;

entity Prescaler is
  generic (
    IN_FREQ_HZ : integer := 12000000;
    OUT_FREQ_HZ : integer := 9600
  );
  port (
    clk, rst : in  STD_LOGIC;
    clk_en_prescaled : out STD_LOGIC
  );
end entity;

architecture Behavioral of Prescaler is
  constant PRESCALE_COUNTER_HALF : integer := ((IN_FREQ_HZ / OUT_FREQ_HZ) / 2) + 2;
  constant PRESCALE_COUNTER_END : integer := (IN_FREQ_HZ / OUT_FREQ_HZ);
  signal counter : integer := PRESCALE_COUNTER_HALF;
begin

  PRESCALER: process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        -- Start with half clock cycle until rising_edge
        -- To be able to reset Prescaler at falling edge on UART start bit to get values in the mid of a bit.
        counter <= PRESCALE_COUNTER_HALF;
        clk_en_prescaled <= '0';
      else
        counter <= counter + 1;
        clk_en_prescaled <= '0';
        -- integer gets truncated in VHDL
        if counter >= PRESCALE_COUNTER_END then
          clk_en_prescaled <= '1';
          counter <= 1;
        end if;
      end if;
    end if;
  end process;

end architecture;