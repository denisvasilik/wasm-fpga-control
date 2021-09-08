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

  signal EngineState : std_logic_vector(7 downto 0);
  signal EngineRun : std_logic;
  signal EngineBusy : std_logic;

  constant ControlStateIdle0 : std_logic_vector(7 downto 0) := x"00";
  constant ControlStateLoaderRun0 : std_logic_vector(7 downto 0) := x"01";
  constant ControlStateLoaderRun1 : std_logic_vector(7 downto 0) := x"02";
  constant ControlStateEngineRun0 : std_logic_vector(7 downto 0) := x"03";
  constant ControlStateEngineRun1 : std_logic_vector(7 downto 0) := x"04";
  constant ControlStateBannerRun0 : std_logic_vector(7 downto 0) := x"05";
  constant ControlStateEnd0 : std_logic_vector(7 downto 0) := x"06";

  constant LoaderStateIdle0 : std_logic_vector(7 downto 0) := x"00";
  constant LoaderStateLoad0 : std_logic_vector(7 downto 0) := x"01";
  constant LoaderStateLoad1 : std_logic_vector(7 downto 0) := x"02";

  constant EngineStateIdle0 : std_logic_vector(7 downto 0) := x"00";
  constant EngineStateRun0 : std_logic_vector(7 downto 0) := x"01";

  constant UartStateIdle0 : std_logic_vector(7 downto 0) := x"00";
  constant UartStateRun0 : std_logic_vector(7 downto 0) := x"01";
  constant UartStateRun1 : std_logic_vector(7 downto 0) := x"02";
  constant UartStateRun2 : std_logic_vector(7 downto 0) := x"03";

begin

  Rst <= not nRst;

  Control : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      Busy <= '1';
      LoaderRun <= '0';
      EngineRun <= '0';
      ControlState <= ControlStateIdle0;
    elsif rising_edge(Clk) then
      if (ControlState = ControlStateIdle0) then
        Busy <= '0';
        if (Run = '1') then
          LoaderRun <= '1';
          Busy <= '1';
          ControlState <= ControlStateLoaderRun0;
        end if;
      elsif (ControlState = ControlStateLoaderRun0) then
        LoaderRun <= '0';
        ControlState <= ControlStateLoaderRun1;
      elsif (ControlState = ControlStateLoaderRun1) then
        if (LoaderBusy ='0') then
          EngineRun <= '1';
          ControlState <= ControlStateEngineRun0;
        end if;
      elsif (ControlState = ControlStateEngineRun0) then
        ControlState <= ControlStateEngineRun1;
      elsif (ControlState = ControlStateEngineRun1) then
        EngineRun <= '0';
        if (EngineBusy ='0') then
          ControlState <= ControlStateEnd0;
        end if;
      elsif (ControlState = ControlStateEnd0) then
        -- End reached
      end if;
    end if;
  end process;

  Loader : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      LoaderBusy <= '0';
      Loader_Cyc <= (others => '0');
      Loader_Stb <= '0';
      Loader_We <= '0';
      Loader_Sel <= (others => '0');
      Loader_Adr <= (others => '0');
      Loader_DatOut <= (others => '0');
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
          Loader_Sel <= (others => '1');
          Loader_Adr <= WASMFPGALOADER_ADR_ControlReg;
          Loader_DatOut <= (31 downto 1 => '0') & WASMFPGALOADER_VAL_DoRun;
          LoaderState <= LoaderStateLoad0;
        end if;
      --
      -- Start module loading
      --
      elsif( LoaderState = LoaderStateLoad0 ) then
        if ( Loader_Ack = '1' ) then
          Loader_Adr <= WASMFPGALOADER_ADR_StatusReg;
          Loader_We <= '0';
          LoaderState <= LoaderStateLoad1;
        end if;
      --
      -- Wait until module loading has been finished.
      --
      elsif( LoaderState = LoaderStateLoad1 ) then
        if ( Loader_Ack = '1' ) then
          if((Loader_DatIn and WASMFPGALOADER_BUS_MASK_Loaded) = WASMFPGALOADER_BUS_MASK_Loaded) then
            LoaderState <= LoaderStateIdle0;
          end if;
        end if;
      end if;
    end if;
  end process;

  Engine : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      EngineBusy <= '0';
      Engine_Cyc <= (others => '0');
      Engine_Stb <= '0';
      Engine_Sel <= (others => '0');
      Engine_We <= '0';
      Engine_Adr <= (others => '0');
      Engine_DatOut <= (others => '0');
      EngineState <= EngineStateIdle0;
    elsif rising_edge(Clk) then
      if( EngineState = EngineStateIdle0 ) then
        EngineBusy <= '0';
        Engine_Cyc <= (others => '0');
        Engine_Stb <= '0';
        Engine_We <= '0';
        Engine_Adr <= (others => '0');
        Engine_Sel <= (others => '0');
        if( EngineRun = '1' ) then
          EngineBusy <= '1';
          Engine_Cyc <= "1";
          Engine_Stb <= '1';
          Engine_Sel <= (others => '1');
          Engine_We <= '1';
          Engine_Adr <= WASMFPGAENGINE_ADR_ControlReg;
          Engine_DatOut <= (31 downto 1 => '0') & WASMFPGAENGINE_VAL_DoRun;
          EngineState <= EngineStateRun0;
        end if;
      elsif( EngineState = EngineStateRun0 ) then
        if ( Engine_Ack = '1' ) then
          EngineState <= EngineStateIdle0;
        end if;
      end if;
    end if;
  end process;

end;
