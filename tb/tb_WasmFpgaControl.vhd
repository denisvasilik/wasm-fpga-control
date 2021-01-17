library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.tb_types.all;

entity tb_WasmFpgaControl is
    generic (
        stimulus_path : string := "../../../../../simstm/";
        stimulus_file : string := "WasmFpgaControl.stm"
    );
end;

architecture behavioural of tb_WasmFpgaControl is

    constant CLK100M_PERIOD : time := 10 ns;

    signal Clk100M : std_logic := '0';
    signal Rst : std_logic := '1';
    signal nRst : std_logic := '0';

    signal WasmFpgaControl_FileIO : T_WasmFpgaControl_FileIO;
    signal FileIO_WasmFpgaControl : T_FileIO_WasmFpgaControl;

    component tb_FileIO is
      generic (
        stimulus_path: in string;
        stimulus_file: in string
      );
      port (
        Clk : in std_logic;
        Rst : in std_logic;
        WasmFpgaControl_FileIO : in T_WasmFpgaControl_FileIO;
        FileIO_WasmFpgaControl : out T_FileIO_WasmFpgaControl
      );
    end component;

begin

	nRst <= not Rst;

    Clk100MGen : process is
    begin
        Clk100M <= not Clk100M;
        wait for CLK100M_PERIOD / 2;
    end process;

    RstGen : process is
    begin
        Rst <= '1';
        wait for 100ns;
        Rst <= '0';
        wait;
    end process;

    tb_FileIO_i : tb_FileIO
        generic map (
            stimulus_path => stimulus_path,
            stimulus_file => stimulus_file
        )
        port map (
            Clk => Clk100M,
            Rst => Rst,
            WasmFpgaControl_FileIO => WasmFpgaControl_FileIO,
            FileIO_WasmFpgaControl => FileIO_WasmFpgaControl
        );

    WasmFpgaControl_i : entity work.WasmFpgaControl
        port map (
            Clk => Clk100M,
            nRst => nRst,
            Run => FileIO_WasmFpgaControl.Run,
            Debug => FileIO_WasmFpgaControl.Debug,
            Busy => WasmFpgaControl_FileIO.Busy,
            Loader_Adr => open,
            Loader_Sel => open,
            Loader_DatIn => (others => '0'),
            Loader_We => open,
            Loader_Stb => open,
            Loader_Cyc => open,
            Loader_DatOut => open,
            Loader_Ack => '0',
            Engine_Adr => open,
            Engine_Sel => open,
            Engine_DatIn => (others => '0'),
            Engine_We => open,
            Engine_Stb => open,
            Engine_Cyc => open,
            Engine_DatOut => open,
            Engine_Ack => '0'
        );

end;