library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_Unit is
  Generic (
    IN_FREQ_HZ : integer := 12000000;
    BAUD_FREQ_HZ : integer := 9600;
    DATA_BITS : integer := 8;
    STOP_BITS : integer := 1
  );
  Port ( 
    clk, rst : in STD_LOGIC;
    send_data : in std_logic_vector(DATA_BITS-1 downto 0);
    write_en : in std_logic;
    full : out std_logic;
    TX_pin : out std_logic;

    received_data : out std_logic_vector(DATA_BITS-1 downto 0);
    new_data_received : out std_logic;
    RX_pin : in std_logic
  );
end UART_Unit;

architecture Behavioral of UART_Unit is
  component UART_Transmitter
    Generic (
      IN_FREQ_HZ : integer := 12000000;
      BAUD_FREQ_HZ : integer := 9600;
      DATA_BITS : integer := 8;
      STOP_BITS : integer := 1
    );
    Port ( 
      clk, rst : in std_logic;
      data_in : in std_logic_vector(DATA_BITS-1 downto 0);
      write_en : in std_logic;
      full : out std_logic;
      serial_out : out std_logic
    );
  end component;
  component UART_Receiver
    Generic(
      IN_FREQ_HZ : integer := 12000000;
      BAUD_FREQ_HZ : integer := 9600;
      DATA_BITS : integer := 8;
      STOP_BITS : integer := 1
    );
    Port ( 
      clk, rst : in std_logic;
      serial_in : in std_logic;
      parallel_out : out std_logic_vector(DATA_BITS-1 downto 0);
      new_data : out std_logic
    );
  end component;
begin
  TRANSMITTER: UART_Transmitter generic map(IN_FREQ_HZ, BAUD_FREQ_HZ, DATA_BITS, STOP_BITS) port map(clk, rst, send_data, write_en, full, TX_pin);
  RECEIVER: UART_Receiver generic map(IN_FREQ_HZ, BAUD_FREQ_HZ, DATA_BITS, STOP_BITS) port map(clk, rst, RX_pin, received_data, new_data_received);
  
end Behavioral;
