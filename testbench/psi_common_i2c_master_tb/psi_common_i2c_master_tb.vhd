------------------------------------------------------------
-- Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
-- All rights reserved.
------------------------------------------------------------

------------------------------------------------------------
-- Testbench generated by TbGen.py
------------------------------------------------------------
-- see Library/Python/TbGenerator

------------------------------------------------------------
-- Libraries
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.psi_common_math_pkg.all;
use work.psi_common_logic_pkg.all;
use work.psi_common_i2c_master_pkg.all;

library work;
use work.psi_tb_compare_pkg.all;
use work.psi_tb_activity_pkg.all;
use work.psi_tb_txt_util.all;
use work.psi_tb_i2c_pkg.all;

------------------------------------------------------------
-- Entity Declaration
------------------------------------------------------------
entity psi_common_i2c_master_tb is
  generic(
    InternalTriState_g : boolean := true
  );
end entity;

------------------------------------------------------------
-- Architecture
------------------------------------------------------------
architecture sim of psi_common_i2c_master_tb is
  -- *** Fixed Generics ***
  constant ClockFrequency_g : real := 125.0e6;
  constant I2cFrequency_g   : real := 1.0e6;
  constant BusBusyTimeout_g : real := 50.0e-6;
  constant CmdTimeout_g     : real := 10.0e-6;

  -- *** Not Assigned Generics (default values) ***

  -- *** TB Control ***
  signal TbRunning            : boolean                  := True;
  signal NextCase             : integer                  := -1;
  signal ProcessDone          : std_logic_vector(0 to 1) := (others => '0');
  constant AllProcessesDone_c : std_logic_vector(0 to 1) := (others => '1');
  constant TbProcNr_stim_c    : integer                  := 0;
  constant TbProcNr_i2c_c     : integer                  := 1;
  signal StimCase             : integer                  := -1;
  signal I2cCase              : integer                  := -1;

  -- *** DUT Signals ***
  signal Clk        : std_logic                    := '1';
  signal Rst        : std_logic                    := '1';
  signal CmdRdy     : std_logic                    := '0';
  signal CmdVld     : std_logic                    := '0';
  signal CmdType    : std_logic_vector(2 downto 0) := (others => '0');
  signal CmdData    : std_logic_vector(7 downto 0) := (others => '0');
  signal CmdAck     : std_logic                    := '0';
  signal RspVld     : std_logic                    := '0';
  signal RspData    : std_logic_vector(7 downto 0) := (others => '0');
  signal RspType    : std_logic_vector(2 downto 0) := (others => '0');
  signal RspArbLost : std_logic                    := '0';
  signal RspAck     : std_logic                    := '0';
  signal RspSeq     : std_logic                    := '0';
  signal BusBusy    : std_logic                    := '0';
  signal TimeoutCmd : std_logic                    := '0';
  signal I2cScl     : std_logic                    := '0';
  signal I2cSda     : std_logic                    := '0';
  signal I2cScl_I   : std_logic                    := '0';
  signal I2cScl_O   : std_logic                    := '0';
  signal I2cScl_T   : std_logic                    := '0';
  signal I2cSda_I   : std_logic                    := '0';
  signal I2cSda_O   : std_logic                    := '0';
  signal I2cSda_T   : std_logic                    := '0';

  -- *** Helper Functions ***
  procedure WaitForCase(signal TestCase : in integer;
                        Value           : in integer) is
  begin
    if TestCase /= Value then
      wait until TestCase = Value;
    end if;
  end procedure;

  procedure ApplyCmd(Command        : in std_logic_vector(2 downto 0);
                     Data           : in std_logic_vector(7 downto 0);
                     Ack            : in std_logic;
                     signal CmdVld  : out std_logic;
                     signal CmdRdy  : in std_logic;
                     signal CmdType : out std_logic_vector(2 downto 0);
                     signal CmdData : out std_logic_vector(7 downto 0);
                     signal CmdAck  : out std_logic) is
  begin
    wait until rising_edge(Clk);
    CmdVld  <= '1';
    CmdType <= Command;
    CmdData <= Data;
    CmdAck  <= Ack;
    wait until rising_edge(Clk) and CmdRdy = '1';
    CmdVld  <= '0';
    CmdType <= (others => '0');
    CmdData <= (others => '0');
    CmdAck  <= '0';
  end procedure;

  procedure CheckRsp(Command           : in std_logic_vector(2 downto 0);
                     Data              : in std_logic_vector;
                     Ack               : in std_logic;
                     ArbLost           : in std_logic;
                     signal RspVld     : in std_logic;
                     signal RspData    : in std_logic_vector(7 downto 0);
                     signal RspType    : in std_logic_vector(2 downto 0);
                     signal RspArbLost : in std_logic;
                     signal RspAck     : in std_logic;
                     signal RspSeq     : in std_logic;
                     Msg               : in string    := "No Msg";
                     Err               : in std_logic := '0') is
  begin
    wait until rising_edge(Clk) and RspVld = '1';
    StdlvCompareStdlv(Command, RspType, "Response: Wrong Type - " & Msg);
    if Data /= "X" then
      StdlvCompareStdlv(Data, RspData, "Response: Wrong Data - " & Msg);
    end if;
    if Ack /= 'X' then
      StdlCompare(choose(Ack = '1', 1, 0), RspAck, "Response: Wrong Ack - " & Msg);
    end if;
    if ArbLost /= 'X' then
      StdlCompare(choose(ArbLost = '1', 1, 0), RspArbLost, "Response: Wrong ArbLost - " & Msg);
    end if;
    StdlCompare(choose(Err = '1', 1, 0), RspSeq, "Response: Wrong Err - " & Msg);
  end procedure;

begin
  ------------------------------------------------------------
  -- DUT Instantiation
  ------------------------------------------------------------
  i_dut : entity work.psi_common_i2c_master
    generic map(
      ClockFrequency_g   => ClockFrequency_g,
      I2cFrequency_g     => I2cFrequency_g,
      BusBusyTimeout_g   => BusBusyTimeout_g,
      CmdTimeout_g       => CmdTimeout_g,
      InternalTriState_g => InternalTriState_g,
      DisableAsserts_g   => true
    )
    port map(
      Clk        => Clk,
      Rst        => Rst,
      CmdRdy     => CmdRdy,
      CmdVld     => CmdVld,
      CmdType    => CmdType,
      CmdData    => CmdData,
      CmdAck     => CmdAck,
      RspVld     => RspVld,
      RspType    => RspType,
      RspArbLost => RspArbLost,
      RspData    => RspData,
      RspAck     => RspAck,
      RspSeq     => RspSeq,
      BusBusy    => BusBusy,
      TimeoutCmd => TimeoutCmd,
      I2cScl     => I2cScl,
      I2cSda     => I2cSda,
      I2cScl_I   => I2cScl_I,
      I2cScl_O   => I2cScl_O,
      I2cScl_T   => I2cScl_T,
      I2cSda_I   => I2cSda_I,
      I2cSda_O   => I2cSda_O,
      I2cSda_T   => I2cSda_T
    );

  ------------------------------------------------------------
  -- I2C Emulation
  ------------------------------------------------------------		
  I2cPullup(I2cScl, I2cSda);
  g_triState : if not InternalTriState_g generate
    I2cScl   <= 'Z' when I2cScl_T = '1' else I2cScl_O;
    I2cScl_I <= To01X(I2cScl);
    I2cSda   <= 'Z' when I2cSda_T = '1' else I2cSda_O;
    I2cSda_I <= To01X(I2cSda);
  end generate;

  ------------------------------------------------------------
  -- Testbench Control !DO NOT EDIT!
  ------------------------------------------------------------
  p_tb_control : process
  begin
    wait until Rst = '0';
    wait until ProcessDone = AllProcessesDone_c;
    TbRunning <= false;
    wait;
  end process;

  ------------------------------------------------------------
  -- Clocks !DO NOT EDIT!
  ------------------------------------------------------------
  p_clock_Clk : process
    constant Frequency_c : real := real(125e6);
  begin
    while TbRunning loop
      wait for 0.5 * (1 sec) / Frequency_c;
      Clk <= not Clk;
    end loop;
    wait;
  end process;

  ------------------------------------------------------------
  -- Resets
  ------------------------------------------------------------
  p_rst_Rst : process
  begin
    wait for 1 us;
    -- Wait for two clk edges to ensure reset is active for at least one edge
    wait until rising_edge(Clk);
    wait until rising_edge(Clk);
    Rst <= '0';
    wait;
  end process;

  ------------------------------------------------------------
  -- Processes
  ------------------------------------------------------------
  -- *** stim ***
  p_stim : process
  begin
    I2cSetFrequency(I2cFrequency_g);
    -- start of process !DO NOT EDIT
    wait until Rst = '0';
    wait until rising_edge(Clk);

    -- *** Test Bus Busy ***
    print(">> Test Bus Busy");
    StimCase <= 0;
    wait until rising_edge(Clk);
    WaitForCase(I2cCase, 0);
    wait for 10 us;

    -- *** Test Start / Repeated-Start / Stop ***
    print(">> Test Start / Repeated-Start / Stop");
    StimCase <= 1;
    wait until rising_edge(Clk);
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start");
    ApplyCmd(CMD_REPSTART, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REPSTART, "X", 'X', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop");
    WaitForCase(I2cCase, 1);
    wait for 10 us;

    -- *** Test Write ***
    print(">> Test Write");
    StimCase <= 2;
    wait until rising_edge(Clk);

    -- 1Byte ACK
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 1b ACK");
    ApplyCmd(CMD_SEND, X"A3", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 1b ACK");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop 1b ACK");

    -- 2Byte ACK, then NACK
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b ACK -> NACK");
    ApplyCmd(CMD_SEND, X"12", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b ACK -> NACK 1");
    ApplyCmd(CMD_SEND, X"34", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '0', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b ACK -> NACK 2");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop 2b ACK -> NACK");

    WaitForCase(I2cCase, 2);
    wait for 10 us;

    -- *** Test Read ***
    print(">> Test Read");
    StimCase <= 3;
    wait until rising_edge(Clk);

    -- 1Byte ACK
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 1b ACK");
    ApplyCmd(CMD_REC, X"00", '1', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REC, X"67", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 1b ACK");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop 1b ACK");

    -- 2Byte ACK, then NACK
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b ACK -> NACK");
    ApplyCmd(CMD_REC, X"00", '1', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REC, X"34", 'X', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b ACK -> NACK 1");
    ApplyCmd(CMD_REC, X"00", '0', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REC, X"56", 'X', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b ACK -> NACK 2");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop 2b ACK -> NACK");

    WaitForCase(I2cCase, 3);
    wait for 10 us;

    -- *** Test Clock Stretching ***
    print(">> Test Clock Stretching");
    StimCase <= 4;
    wait until rising_edge(Clk);

    -- 1Byte Read ACK
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Read 1b ACK");
    ApplyCmd(CMD_REC, X"00", '1', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REC, X"67", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Read 1b ACK");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop Read 1b ACK");

    -- 2Byte ACK, then NACK
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b Write ACK -> NACK");
    ApplyCmd(CMD_SEND, X"12", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b Write ACK -> NACK 1");
    ApplyCmd(CMD_SEND, X"34", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '0', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b Write ACK -> NACK 2");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop 2b Write ACK -> NACK");

    -- Write / Read
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 2b W->R");
    ApplyCmd(CMD_SEND, X"12", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Write 2b W->R");
    ApplyCmd(CMD_REPSTART, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REPSTART, "X", 'X', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "RepStart 2b W->R");
    ApplyCmd(CMD_REC, X"00", '1', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REC, X"67", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Read 2b W->R");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop 2b W->R");

    WaitForCase(I2cCase, 4);
    wait for 10 us;

    -- *** Test Delayed Command *** (clock is held low until command available)
    print(">> Test Delayed Command");
    StimCase <= 5;
    wait until rising_edge(Clk);

    -- 1Byte Read ACK, delay shorter than timeout
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Read 1b ACK");
    wait for CmdTimeout_g / 2.0 * (1 sec);
    wait until rising_edge(Clk);
    ApplyCmd(CMD_REC, X"00", '1', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REC, X"67", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Read 1b ACK");
    wait for CmdTimeout_g / 2.0 * (1 sec);
    wait until rising_edge(Clk);
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop Read 1b ACK");

    -- Command Timeout (Timeout after start, other commands ignored)
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Read 1b ACK");
    wait for CmdTimeout_g * 2.0 * (1 sec);
    wait until rising_edge(Clk);
    ApplyCmd(CMD_REC, X"00", '1', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REC, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Read 1b ACK", Err => '1');
    wait for CmdTimeout_g * 2.0 * (1 sec);
    wait until rising_edge(Clk);
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop Read 1b ACK", Err => '1');

    WaitForCase(I2cCase, 5);
    wait for 10 us;

    -- *** Test Arbitration *** 
    print(">> Test Arbitration");
    StimCase <= 6;
    wait until rising_edge(Clk);

    -- Multi Master, Same Write 
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 1b ACK");
    ApplyCmd(CMD_SEND, X"A3", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start 1b ACK");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop 1b ACK");

    -- Arbitration Lost during Write
    wait for 10 us;
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost Write");
    ApplyCmd(CMD_SEND, X"A3", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '0', '1', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost Write");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Lost Write", Err => '1');

    -- Arbitration Lost during STOP (other master continues writing)
    wait for 10 us;
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost Stop");
    ApplyCmd(CMD_SEND, X"A3", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost Stop");
    ApplyCmd(CMD_STOP, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_STOP, "X", 'X', '1', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Stop Lost Stop");

    -- Arbitration Lost during repeated start (other master continues writing)
    wait for 20 us;
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost RepStartA");
    ApplyCmd(CMD_SEND, X"A3", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost RepStartA");
    ApplyCmd(CMD_REPSTART, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REPSTART, "X", 'X', '1', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Repstart Lost RepStartA");

    -- Arbitration Lost during repeated start (other master stops)
    wait for 20 us;
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost RepStartB");
    ApplyCmd(CMD_SEND, X"A3", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost RepStartB");
    ApplyCmd(CMD_REPSTART, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_REPSTART, "X", 'X', '1', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Repstart Lost RepStartB");

    -- Arbitration lost due to stop (during first bit of data)
    wait for 10 us;
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost DueStop");
    ApplyCmd(CMD_SEND, X"A3", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost DueStop 1");
    ApplyCmd(CMD_SEND, X"F0", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '0', '1', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost DueStop 2");

    -- Arbitration lost due to rep-start (during first bit of data)
    wait for 10 us;
    ApplyCmd(CMD_START, X"00", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_START, "X", 'X', 'X', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost DueRepStart");
    ApplyCmd(CMD_SEND, X"A3", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '1', '0', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost DueRepStart 1");
    ApplyCmd(CMD_SEND, X"F0", 'X', CmdVld, CmdRdy, CmdType, CmdData, CmdAck);
    CheckRsp(CMD_SEND, "X", '0', '1', RspVld, RspData, RspType, RspArbLost, RspAck, RspSeq, "Start Lost DueRepStart 2");

    WaitForCase(I2cCase, 6);
    wait for 10 us;

    -- end of process !DO NOT EDIT!
    wait for 1 us;
    ProcessDone(TbProcNr_stim_c) <= '1';
    wait;
  end process;

  -- *** i2c slave ***
  p_i2c_slave : process
  begin
    I2cBusFree(I2cScl, I2cSda);

    -- start of process !DO NOT EDIT
    wait until Rst = '0';
    wait until rising_edge(Clk);

    -- *** Test Bus Busy ***
    WaitForCase(StimCase, 0);
    -- Not busy
    wait for 1 us;
    StdlCompare(0, BusBusy, "Busy 0");
    -- A transfer is goiong on
    I2cScl  <= '0';
    wait for 1 us;
    StdlCompare(1, BusBusy, "Busy 1");
    -- busy is kept
    I2cScl  <= 'Z';
    wait for 10 us;
    StdlCompare(1, BusBusy, "Busy 2");
    -- released after timeout
    wait for BusBusyTimeout_g * (1 sec);
    StdlCompare(0, BusBusy, "Busy 3");
    -- Asserted on start
    I2cMasterSendStart(I2cScl, I2cSda, "Assert Start");
    wait for 1 us;
    StdlCompare(1, BusBusy, "Busy 4");
    -- Released on stop
    I2cMasterSendStop(I2cScl, I2cSda, "Assert Start");
    wait for 1 us;
    StdlCompare(0, BusBusy, "Busy 4");
    I2cCase <= 0;

    -- *** Test Start / Stop ***
    WaitForCase(StimCase, 1);
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start");
    I2cSlaveWaitRepeatedStart(I2cScl, I2cSda, "RepStart");
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop");
    I2cCase <= 1;

    -- *** Test Write ***
    WaitForCase(StimCase, 2);

    -- 1 Byte Ack
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start 1b Ack");
    I2cSlaveExpectByte(16#A3#, I2cScl, I2cSda, "Data 1b Ack", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop");

    -- 2 Byte Ack, then NACK
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start 2b ACK -> NACK");
    I2cSlaveExpectByte(16#12#, I2cScl, I2cSda, "Data 2b ACK -> NACK 1", '0');
    I2cSlaveExpectByte(16#34#, I2cScl, I2cSda, "Data 2b ACK -> NACK 2", '1');
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop");

    I2cCase <= 2;

    -- *** Test Read ***
    WaitForCase(StimCase, 3);

    -- 1 Byte Ack
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start 1b Ack");
    I2cSlaveSendByte(16#67#, I2cScl, I2cSda, "Data 1b Ack", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop");

    -- 2 Byte Ack, then NACK
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start 2b ACK -> NACK");
    I2cSlaveSendByte(16#34#, I2cScl, I2cSda, "Data 2b ACK -> NACK 1", '0');
    I2cSlaveSendByte(16#56#, I2cScl, I2cSda, "Data 2b ACK -> NACK 2", '1');
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop");

    I2cCase <= 3;

    -- *** Test Clock Stretching ***
    WaitForCase(StimCase, 4);

    -- 1 Byte Read Ack
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start Read 1b Ack");
    I2cSlaveSendByte(16#67#, I2cScl, I2cSda, "Data Write 1b Ack", '0', ClkStretch => 1 us);
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop", ClkStretch => 1 us);

    -- 2 Byte Write Ack, then NACK
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start 2b Write ACK -> NACK");
    I2cSlaveExpectByte(16#12#, I2cScl, I2cSda, "Data 2b Write ACK -> NACK 1", '0', ClkStretch => 1 us);
    I2cSlaveExpectByte(16#34#, I2cScl, I2cSda, "Data 2b Write ACK -> NACK 2", '1', ClkStretch => 1 us);
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop", ClkStretch => 1 us);

    -- Write / Read
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start 2b W->R");
    I2cSlaveExpectByte(16#12#, I2cScl, I2cSda, "Write 2b W->R", '0', ClkStretch => 1 us);
    I2cSlaveWaitRepeatedStart(I2cScl, I2cSda, "RepStart 2b W->R", ClkStretch => 1 us);
    I2cSlaveSendByte(16#67#, I2cScl, I2cSda, "Read 2b W->R", '0', ClkStretch => 1 us);
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop 2b W->R", ClkStretch => 1 us);

    I2cCase <= 4;

    -- *** Test Delayed Command *** 
    WaitForCase(StimCase, 5);

    -- 1 Byte Ack, delay shorter than timeout
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start 1b Ack");
    I2cSlaveSendByte(16#67#, I2cScl, I2cSda, "Data 1b Ack", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop");

    -- Command Timeout (Timeout after start, stop generated internally)
    I2cSlaveWaitStart(I2cScl, I2cSda, "Start 1b Ack");
    I2cSlaveWaitStop(I2cScl, I2cSda, "Stop");

    I2cCase <= 5;

    -- *** Test Arbitration ***
    WaitForCase(StimCase, 6);

    -- Multi Master, Same Write 
    I2cSlaveWaitStart(I2cScl, I2cSda, "S: Start 1b Ack");
    I2cSlaveExpectByte(16#A3#, I2cScl, I2cSda, "S: Data 1b Ack", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "S: Stop");

    -- Arbitration Lost during Write
    I2cSlaveWaitStart(I2cScl, I2cSda, "S: Start Lost Write");
    I2cSlaveExpectByte(16#87#, I2cScl, I2cSda, "S: Stop Lost Write", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "S: Lost Write Stop");

    -- Arbitration Lost STOP (other master continues writing)
    I2cSlaveWaitStart(I2cScl, I2cSda, "S: Start Lost Stop");
    I2cSlaveExpectByte(16#A3#, I2cScl, I2cSda, "S: Data Lost Stop 1", '0');
    I2cSlaveExpectByte(16#12#, I2cScl, I2cSda, "S: Data Lost Stop 2", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "S: Stop Lost Stop");

    -- Arbitration Lost during repeated start (other master continues writing)
    I2cSlaveWaitStart(I2cScl, I2cSda, "S: Start Lost RepStartA");
    I2cSlaveExpectByte(16#A3#, I2cScl, I2cSda, "S: Data Lost RepStartA 1", '0');
    I2cSlaveExpectByte(16#12#, I2cScl, I2cSda, "S: Data Lost RepStartA 2", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "S: Stop Lost RepStartA");

    -- Arbitration Lost during repeated start (other master stops)
    I2cSlaveWaitStart(I2cScl, I2cSda, "S: Start Lost RepStartB");
    I2cSlaveExpectByte(16#A3#, I2cScl, I2cSda, "S: Data Lost RepStartB 1", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "S: Stop Lost RepStartB");

    -- Arbitration lost due to stop (during first bit of data)
    I2cSlaveWaitStart(I2cScl, I2cSda, "S: Start Lost DueStop");
    I2cSlaveExpectByte(16#A3#, I2cScl, I2cSda, "S: Data Lost DueStop 1", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "S: Stop Lost DueStop");

    -- Arbitration lost due to rep-start (during first bit of data)
    I2cSlaveWaitStart(I2cScl, I2cSda, "S: Start Lost RepStart");
    I2cSlaveExpectByte(16#A3#, I2cScl, I2cSda, "S: Write Lost RepStart 1", '0');
    I2cSlaveWaitRepeatedStart(I2cScl, I2cSda, "S: Lost RepStart RepStart");
    I2cSlaveSendByte(16#34#, I2cScl, I2cSda, "S: Read Lost RepStart RepStart", '0');
    I2cSlaveWaitStop(I2cScl, I2cSda, "S: Stop Lost RepStart");

    I2cCase <= 6;

    -- end of process !DO NOT EDIT!
    ProcessDone(TbProcNr_i2c_c) <= '1';
    wait;
  end process;

  -- *** i2c master ***
  p_i2c_master : process
  begin
    I2cBusFree(I2cScl, I2cSda);

    -- *** Test Arbitration ***
    WaitForCase(StimCase, 6);

    -- Multi Master, Same Write 
    I2cSlaveWaitStart(I2cScl, I2cSda, "M: Start 1b Ack");
    -- small delay
    I2cScl <= '0';
    wait for 100 ns;
    -- continue
    I2cMasterSendByte(16#A3#, I2cScl, I2cSda, "M: Data 1b Ack");
    I2cMasterSendStop(I2cScl, I2cSda, "M: Stop");

    -- Arbitration Lost during Write
    I2cSlaveWaitStart(I2cScl, I2cSda, "M: Start Lost Write");
    I2cMasterSendByte(16#87#, I2cScl, I2cSda, "M: Data Lost Write");
    I2cMasterSendStop(I2cScl, I2cSda, "M: Stop Loast Read");

    -- Arbitration Lost STOP (other master continues writing)
    I2cSlaveWaitStart(I2cScl, I2cSda, "M: Start Lost Stop");
    I2cMasterSendByte(16#A3#, I2cScl, I2cSda, "M: Data Lost Stop 1");
    I2cMasterSendByte(16#12#, I2cScl, I2cSda, "M: Data Lost Stop 2");
    I2cMasterSendStop(I2cScl, I2cSda, "M: Stop Lost Stop");

    -- Arbitration Lost during repeated start (other master continues writing)
    I2cSlaveWaitStart(I2cScl, I2cSda, "M: Start Lost RepStartA");
    I2cMasterSendByte(16#A3#, I2cScl, I2cSda, "M: Data Lost RepStartA 1");
    I2cMasterSendByte(16#12#, I2cScl, I2cSda, "M: Data Lost RepStartA 2");
    I2cMasterSendStop(I2cScl, I2cSda, "M: Stop Lost RepStartA");

    -- Arbitration Lost during repeated start (other master stops)
    I2cSlaveWaitStart(I2cScl, I2cSda, "M: Start Lost RepStartB");
    I2cMasterSendByte(16#A3#, I2cScl, I2cSda, "M: Data Lost RepStartB 1");
    I2cMasterSendStop(I2cScl, I2cSda, "M: Stop Lost RepStartB");

    -- Arbitration lost due to stop (during first bit of data)
    I2cSlaveWaitStart(I2cScl, I2cSda, "M: Start Lost DueStop");
    I2cMasterSendByte(16#A3#, I2cScl, I2cSda, "M: Data Lost DueStop 1");
    I2cMasterSendStop(I2cScl, I2cSda, "M: Stop Lost DueStop");

    -- Arbitration lost due to rep-start (during first bit of data)
    I2cSlaveWaitStart(I2cScl, I2cSda, "M: Start Lost DueRepstart");
    I2cMasterSendByte(16#A3#, I2cScl, I2cSda, "M: write Lost DueRepstart 1");
    I2cMasterSendRepeatedStart(I2cScl, I2cSda, "M: Stop Lost DueRepstart");
    I2cMasterExpectByte(16#34#, I2cScl, I2cSda, "M: read Lost DueRepstart 1");
    I2cMasterSendStop(I2cScl, I2cSda, "M: Stop Lost DueRepstart");

    wait;

  end process;

end;
