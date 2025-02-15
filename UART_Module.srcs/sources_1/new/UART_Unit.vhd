library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_Unit is
  Generic (
    IN_FREQ_HZ : integer := 12000000;
    OUT_FREQ_HZ : integer := 9600
  );
  Port ( 
    clk, rst : in STD_LOGIC;
    send_data : in std_logic_vector(7 downto 0);
    write_en : in std_logic;
    full : out std_logic;
    TX_pin : out std_logic;

    received_data : out std_logic_vector(7 downto 0);
    new_data_received : out std_logic;
    RX_pin : in std_logic
  );
end UART_Unit;

architecture Behavioral of UART_Unit is
  component UART_Sender
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
  end component;
  component UART_Receiver
    Generic(
      IN_FREQ_HZ : integer := 12000000;
      OUT_FREQ_HZ : integer := 9600
    );
    Port ( 
      clk, rst : in std_logic;
      serial_in : in std_logic;
      parallel_out : out std_logic_vector(7 downto 0);
      new_data : out std_logic
    );
  end component;
begin
  SEND: UART_Sender generic map(IN_FREQ_HZ, OUT_FREQ_HZ) port map(clk, rst, send_data, write_en, full, TX_pin);
  RECE: UART_Receiver generic map(IN_FREQ_HZ, OUT_FREQ_HZ) port map(clk, rst, RX_pin, received_data, new_data_received);
  
end Behavioral;
