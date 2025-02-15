library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_UARTUnit is
end TB_UARTUnit;

architecture TESTBENCH of TB_UARTUnit is
    component UART_Unit 
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
    end component;
    signal tb_clk, tb_rst : STD_LOGIC;
    signal tb_send_data : std_logic_vector(4 downto 0);
    signal tb_write_en : std_logic;
    signal tb_full : std_logic;
    signal tb_TX_pin : std_logic;
        
    signal tb_received_data : std_logic_vector(4 downto 0);
    signal tb_new_data_received : std_logic;
    signal tb_RX_pin : std_logic;
    constant tbase : time := 83 ns;
begin
    COMP: UART_Unit generic map(12000000, 9600, 5, 2) port map(tb_clk, tb_rst, tb_send_data, tb_write_en, tb_full, tb_TX_Pin, tb_received_data, tb_new_data_received, tb_RX_pin);
    
    process
    begin
        tb_clk <= '1';
        wait for tbase/2;
        tb_clk <= '0';
        wait for tbase/2;
    end process;
        
    tb_rst <= '1', '0' after 2*tbase;
    tb_send_data <= "01011";
    tb_write_en <= '1';
    tb_RX_pin <= '1';
    -- RX: Verified in practical use with logic analyzer

end TESTBENCH;
