library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaControlPackage.all;
  use work.WasmFpgaLoaderWshBn_Package.all;
  use work.WasmFpgaEngineWshBn_Package.all;

entity WasmFpgaControl is
    port ( 
        Clk : in std_logic;
        nRst : in std_logic;
        Run : in std_logic;
        Debug : in std_logic;
        Busy : out std_logic;
        Loader_Adr : out std_logic_vector(23 downto 0);
        Loader_Sel : out std_logic_vector(3 downto 0);
        Loader_DatIn: in std_logic_vector(31 downto 0);
        Loader_We : out std_logic;
        Loader_Stb : out std_logic;
        Loader_Cyc : out std_logic_vector(0 downto 0);
        Loader_DatOut : out std_logic_vector(31 downto 0);
        Loader_Ack : in std_logic;
        Engine_Adr : out std_logic_vector(23 downto 0);
        Engine_Sel : out std_logic_vector(3 downto 0);
        Engine_DatIn: in std_logic_vector(31 downto 0);
        Engine_We : out std_logic;
        Engine_Stb : out std_logic;
        Engine_Cyc : out std_logic_vector(0 downto 0);
        Engine_DatOut : out std_logic_vector(31 downto 0);
        Engine_Ack : in std_logic
    );
end entity WasmFpgaControl;

architecture WasmFpgaControlArchitecture of WasmFpgaControl is

  signal Rst : std_logic;

  signal ControlState : std_logic_vector(7 downto 0);

  signal LoaderState : std_logic_vector(7 downto 0);
  signal LoaderRun : std_logic;
  signal LoaderBusy : std_logic;
  signal LoaderReadAddress : std_logic_vector(23 downto 0);
  signal LoaderWriteAddress : std_logic_vector(23 downto 0);
  signal LoaderReadData : std_logic_vector(31 downto 0);
  signal LoaderWriteData : std_logic_vector(31 downto 0);

  signal EngineState : std_logic_vector(7 downto 0);
  signal EngineRun : std_logic;
  signal EngineBusy : std_logic;
  signal EngineReadAddress : std_logic_vector(23 downto 0);
  signal EngineWriteAddress : std_logic_vector(23 downto 0);
  signal EngineReadData : std_logic_vector(31 downto 0);
  signal EngineWriteData : std_logic_vector(31 downto 0);

  constant ControlStateIdle0 : std_logic_vector(7 downto 0) := x"00";
  constant ControlStateLoaderRun0 : std_logic_vector(7 downto 0) := x"01";
  constant ControlStateLoaderRun1 : std_logic_vector(7 downto 0) := x"02";
  constant ControlStateEngineRun0 : std_logic_vector(7 downto 0) := x"03";
  constant ControlStateEngineRun1 : std_logic_vector(7 downto 0) := x"04";

  constant LoaderStateIdle0 : std_logic_vector(7 downto 0) := x"00";
  constant LoaderStateWriteCyc0 : std_logic_vector(7 downto 0) := x"01";
  constant LoaderStateWriteAck0 : std_logic_vector(7 downto 0) := x"02";

  constant EngineStateIdle0 : std_logic_vector(7 downto 0) := x"00";
  constant EngineStateReadCyc0 : std_logic_vector(7 downto 0) := x"01";
  constant EngineStateReadAck0 : std_logic_vector(7 downto 0) := x"02";

begin

  Rst <= not nRst;

  Control : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      Busy <= '1';
      LoaderRun <= '0';
      LoaderReadAddress <= (others => '0');
      LoaderWriteAddress <= (others => '0');
      LoaderWriteData <= (others => '0');
      EngineRun <= '0';
      EngineReadAddress <= (others => '0');
      EngineWriteAddress <= (others => '0');
      EngineWriteData <= (others => '0');
      ControlState <= ControlStateIdle0;
    elsif rising_edge(Clk) then
      if (ControlState = ControlStateIdle0) then
        Busy <= '0';
        if (Run = '1') then
          Busy <= '1';
          ControlState <= ControlStateLoaderRun0;
        end if;
      elsif (ControlState = ControlStateLoaderRun0) then
        LoaderWriteAddress <= WASMFPGALOADER_ADR_ControlReg;
        LoaderWriteData <= (31 downto 1 => '0') & WASMFPGALOADER_VAL_DoRun;
        LoaderRun <= '1';
        ControlState <= ControlStateLoaderRun1;
      elsif (ControlState = ControlStateLoaderRun1) then
        LoaderRun <= '0';
        if (LoaderBusy ='0') then
          ControlState <= ControlStateEngineRun0;
        end if;
      elsif (ControlState = ControlStateEngineRun0) then
        EngineWriteAddress <= WASMFPGAENGINE_ADR_ControlReg;
        EngineWriteData <= (31 downto 1 => '0') & WASMFPGAENGINE_VAL_DoRun;
        EngineRun <= '1';
        ControlState <= ControlStateEngineRun1;
      elsif (ControlState = ControlStateEngineRun1) then
        EngineRun <= '0';
        if (EngineBusy ='0') then
          ControlState <= ControlStateIdle0;
        end if;
      end if;
    end if;
  end process;

  Loader : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      LoaderBusy <= '0';
      LoaderReadData <= (others => '0');
      Loader_Cyc <= (others => '0');
      Loader_Stb <= '0';
      Loader_Adr <= (others => '0');
      Loader_Sel <= (others => '0');
      LoaderState <= LoaderStateIdle0;
    elsif rising_edge(Clk) then
      if( LoaderState = LoaderStateIdle0 ) then
        LoaderBusy <= '0';
        Loader_Cyc <= (others => '0');
        Loader_Stb <= '0';
        Loader_Adr <= (others => '0');
        Loader_Sel <= (others => '0');
        if( LoaderRun = '1' ) then
          LoaderBusy <= '1';
          Loader_Cyc <= "1";
          Loader_Stb <= '1';
          Loader_We <= '1';
          Loader_Adr <= LoaderWriteAddress;
          Loader_DatOut <= LoaderWriteData;
          Loader_Sel <= (others => '1');
          LoaderState <= LoaderStateWriteCyc0;
        end if;
      elsif( LoaderState = LoaderStateWriteCyc0 ) then
        if ( Loader_Ack = '1' ) then
          LoaderState <= LoaderStateIdle0;
        end if;
      end if;
    end if;
  end process;

  Engine : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      EngineBusy <= '0';
      EngineReadData <= (others => '0');
      Engine_Cyc <= (others => '0');
      Engine_Stb <= '0';
      Engine_Adr <= (others => '0');
      Engine_Sel <= (others => '0');
      EngineState <= EngineStateIdle0;
    elsif rising_edge(Clk) then
      if( EngineState = EngineStateIdle0 ) then
        EngineBusy <= '0';
        Engine_Cyc <= (others => '0');
        Engine_Stb <= '0';
        Engine_Adr <= (others => '0');
        Engine_Sel <= (others => '0');
        if( LoaderRun = '1' ) then
          EngineBusy <= '1';
          Engine_Cyc <= "1";
          Engine_Stb <= '1';
          Engine_Adr <= "00" & LoaderReadAddress(23 downto 2);
          Engine_Sel <= (others => '1');
          EngineState <= EngineStateReadCyc0;
        end if;
      elsif( EngineState = EngineStateReadCyc0 ) then
        if ( Engine_Ack = '1' ) then
          EngineReadData <= Engine_DatIn;
          EngineState <= EngineStateReadAck0;
        end if;
      elsif( EngineState = EngineStateReadAck0 ) then
        Engine_Cyc <= (others => '0');
        Engine_Stb <= '0';
        EngineBusy <= '0';
        EngineState <= EngineStateIdle0;
      end if;
    end if;
  end process;

end;
