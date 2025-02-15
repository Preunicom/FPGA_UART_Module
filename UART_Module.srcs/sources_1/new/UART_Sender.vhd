library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_Sender is
  Generic (
    IN_FREQ_HZ : integer := 12000000;
    OUT_FREQ_HZ : integer := 9600
  );
  Port ( 
    clk, rst : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    write_en : in std_logic;
    full : out std_logic;
    serial_out : out std_logic
  );
end UART_Sender;

architecture Behavioral of UART_Sender is
  component Prescaler
    Generic(
      IN_FREQ_HZ : integer := 12000000;
      OUT_FREQ_HZ : integer := 9600
    );
    Port ( 
      clk, rst : in STD_LOGIC;
      clk_prescaled : out STD_LOGIC
    );
  end component;
  component Serializer
    Port ( 
        clk, rst, write_enable : in std_logic;
        parallel_in : in std_logic_vector(7 downto 0);
        serial_out : out std_logic;
        read_successfully : out std_logic
      );
  end component;
  component Buffer_Register_Serializer
    Port ( 
      clk, rst, write_enable : in std_logic;
      data_in : in std_logic_vector(7 downto 0);
      shift_reg_read_successfully : in std_logic;
      data_out : out std_logic_vector(7 downto 0);
      full : out std_logic
    );
  end component;
  signal prescaled_clk_intern : std_logic;
  signal data_intern : std_logic_vector(7 downto 0);
  signal read_successfully_intern : std_logic;
  signal full_intern : std_logic;
begin
  PRES: Prescaler generic map(IN_FREQ_HZ, OUT_FREQ_HZ) port map(clk, rst, prescaled_clk_intern);
  BRSER: Buffer_Register_Serializer port map(clk, rst, write_en, data_in, read_successfully_intern, data_intern, full_intern);
  SER: Serializer port map(prescaled_clk_intern, rst, full_intern, data_intern, serial_out, read_successfully_intern);

  full <= full_intern;
  
end Behavioral;
