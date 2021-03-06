--
-- Definition of a dual port ROM for KCPSM2 or KCPSM3 program defined by fg_ctrl.psm
-- and assmbled using KCPSM2 or KCPSM3 assembler.
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
library unisim;
use unisim.vcomponents.all;
--
--
entity fg_ctrl is
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
             proc_reset : out std_logic;
                    clk : in std_logic);
    end fg_ctrl;
--
architecture low_level_definition of fg_ctrl is
--
-- Declare signals internal to this module
--
signal jaddr     : std_logic_vector(10 downto 0);
signal jparity   : std_logic_vector(0 downto 0);
signal jdata     : std_logic_vector(7 downto 0);
signal doa       : std_logic_vector(7 downto 0);
signal dopa      : std_logic_vector(0 downto 0);
signal tdo1      : std_logic;
signal tdo2      : std_logic;
signal update    : std_logic;
signal shift     : std_logic;
signal reset     : std_logic;
signal tdi       : std_logic;
signal sel1      : std_logic;
signal drck1     : std_logic;
signal drck1_buf : std_logic;
signal sel2      : std_logic;
signal drck2     : std_logic;
signal capture   : std_logic;
signal tap5      : std_logic;
signal tap11     : std_logic;
signal tap17     : std_logic;
--
-- Attributes to define ROM contents during implementation synthesis. 
-- The information is repeated in the generic map for functional simulation
--
attribute INIT_00 : string; 
attribute INIT_01 : string; 
attribute INIT_02 : string; 
attribute INIT_03 : string; 
attribute INIT_04 : string; 
attribute INIT_05 : string; 
attribute INIT_06 : string; 
attribute INIT_07 : string; 
attribute INIT_08 : string; 
attribute INIT_09 : string; 
attribute INIT_0A : string; 
attribute INIT_0B : string; 
attribute INIT_0C : string; 
attribute INIT_0D : string; 
attribute INIT_0E : string; 
attribute INIT_0F : string; 
attribute INIT_10 : string; 
attribute INIT_11 : string; 
attribute INIT_12 : string; 
attribute INIT_13 : string; 
attribute INIT_14 : string; 
attribute INIT_15 : string; 
attribute INIT_16 : string; 
attribute INIT_17 : string; 
attribute INIT_18 : string; 
attribute INIT_19 : string; 
attribute INIT_1A : string; 
attribute INIT_1B : string; 
attribute INIT_1C : string; 
attribute INIT_1D : string; 
attribute INIT_1E : string; 
attribute INIT_1F : string; 
attribute INIT_20 : string; 
attribute INIT_21 : string; 
attribute INIT_22 : string; 
attribute INIT_23 : string; 
attribute INIT_24 : string; 
attribute INIT_25 : string; 
attribute INIT_26 : string; 
attribute INIT_27 : string; 
attribute INIT_28 : string; 
attribute INIT_29 : string; 
attribute INIT_2A : string; 
attribute INIT_2B : string; 
attribute INIT_2C : string; 
attribute INIT_2D : string; 
attribute INIT_2E : string; 
attribute INIT_2F : string; 
attribute INIT_30 : string; 
attribute INIT_31 : string; 
attribute INIT_32 : string; 
attribute INIT_33 : string; 
attribute INIT_34 : string; 
attribute INIT_35 : string; 
attribute INIT_36 : string; 
attribute INIT_37 : string; 
attribute INIT_38 : string; 
attribute INIT_39 : string; 
attribute INIT_3A : string; 
attribute INIT_3B : string; 
attribute INIT_3C : string; 
attribute INIT_3D : string; 
attribute INIT_3E : string; 
attribute INIT_3F : string; 
attribute INITP_00 : string;
attribute INITP_01 : string;
attribute INITP_02 : string;
attribute INITP_03 : string;
attribute INITP_04 : string;
attribute INITP_05 : string;
attribute INITP_06 : string;
attribute INITP_07 : string;
--
-- Attributes to define ROM contents during implementation synthesis.
--
attribute INIT_00 of ram_1024_x_18 : label is  "E004E00301010000022601CD01CD01CD01CD019E022B0522018B022B05100215";
attribute INIT_01 of ram_1024_x_18 : label is  "0084E000000001C3C001E0110009E0100004E10BE00AE009E008E007E006E005";
attribute INIT_02 of ram_1024_x_18 : label is  "4B0B503920016B116A10E000A07F502320806000544520024000C080000100B4";
attribute INIT_03 of ram_1024_x_18 : label is  "4A0550414A098A01CB01501F4B034042CA0154424A0550374A09CA018B01501F";
attribute INIT_04 of ram_1024_x_18 : label is  "504A20806000547B20024000C080000200B40084007D401FEB11EA108A015442";
attribute INIT_05 of ram_1024_x_18 : label is  "8B0150614B0BFAB00A094046FAB0505B4AFFCA017AB0506820016B11E000A07F";
attribute INIT_06 of ram_1024_x_18 : label is  "FAB00A004046FAB0506E4A0A8A017AB040638B0150464B0BFAB00A006B114055";
attribute INIT_07 of ram_1024_x_18 : label is  "2002400001C8401F007D40768B0150464B0BFAB00A096B1140688B0150744B0B";
attribute INIT_08 of ram_1024_x_18 : label is  "0B0000A100A164156516661767186819691A6A1B011900E5A000E0000000547D";
attribute INIT_09 of ram_1024_x_18 : label is  "00A9EB20EA1FE91EE81DE71C0700080009000A0854904B1F8B0100A1549A2A18";
attribute INIT_0A of ram_1024_x_18 : label is  "C804C70266206A1F691E681D671CA0000A00090008000700060005000406A000";
attribute INIT_0B of ram_1024_x_18 : label is  "650A00E240C500DF650A00DF50BE4500650B022B0512015DA000C620CA10C908";
attribute INIT_0C of ram_1024_x_18 : label is  "01EB054D00D8020500E200D8020801EB052E00DF650900E240C500DF50C44500";
attribute INIT_0D of ram_1024_x_18 : label is  "8530A00054D9C301C20100DF75200303A000022B8510651001EB057A01EB0548";
attribute INIT_0E of ram_1024_x_18 : label is  "0303080109000A000B00E00FE00EE00DE00C00000209A00001EB0520A00001EB";
attribute INIT_0F of ram_1024_x_18 : label is  "C101E00FB0B0600FE00EB0A0600EE00DB090600DE00C9080600C510141007130";
attribute INIT_10 of ram_1024_x_18 : label is  "BA60B95098400B000A00090008060B000A00090008061480159016A017B040F1";
attribute INIT_11 of ram_1024_x_18 : label is  "E016E017E018E019E01AE01B0000A00054F0C20183010B000A0009000806BB70";
attribute INIT_12 of ram_1024_x_18 : label is  "E017A0846017E016806260165D3C080809080A080B0E0120680C690D6A0E6B0F";
attribute INIT_13 of ram_1024_x_18 : label is  "601AE01B0008601BE01BA0AB601BE01AA0CC601AE019A0776019E018A0116018";
attribute INIT_14 of ram_1024_x_18 : label is  "00086015E01600086016E01700086017E01800086018E01900086019E01A0008";
attribute INIT_15 of ram_1024_x_18 : label is  "054E022B0520A0005525C101E01200086012E01300086013E01400086014E015";
attribute INIT_16 of ram_1024_x_18 : label is  "000E000E1200A000017E602001EB053D01EB054400E20184071F01EB053D01EB";
attribute INIT_17 of ram_1024_x_18 : label is  "1530016DA000803A8007597CC00AA00012000179A00F102013000179000E000E";
attribute INIT_18 of ram_1024_x_18 : label is  "056501EB057201EB05464185B000C601C701017E70700604A00001EB152001EB";
attribute INIT_19 of ram_1024_x_18 : label is  "01EB0547A00001EB057901EB056301EB056E01EB056501EB057501EB057101EB";
attribute INIT_1A of ram_1024_x_18 : label is  "01EB057201EB056F01EB057401EB056101EB057201EB056501EB056E01EB0565";
attribute INIT_1B of ram_1024_x_18 : label is  "01BA0128A00055BBC001000BA00001EB053201EB052E01EB053101EB057600E2";
attribute INIT_1C of ram_1024_x_18 : label is  "C40101C80432A00055C9C30101C30314A00055C4C20101BE0219A00055BFC101";
attribute INIT_1D of ram_1024_x_18 : label is  "01D8C408A4F01450A00001D2C440A4F8A000C440E40101BAC440E401A00055CE";
attribute INIT_1E of ram_1024_x_18 : label is  "01D2C440C40CA4F01450A000C44004F001BE01D80406040604060407145001BA";
attribute INIT_1F of ram_1024_x_18 : label is  "C440E401C440040EA000C44004F001BE01D2C4400406040604070407145001BA";
attribute INIT_20 of ram_1024_x_18 : label is  "000E000E000E000EA5F0C440E401400101BAC440E40101BAC440E401450101BA";
attribute INIT_21 of ram_1024_x_18 : label is  "01BE01D8042001BE01D801C301D801C801D8043001C8A00001BEC4400404D500";
attribute INIT_22 of ram_1024_x_18 : label is  "01DCC580A50F52312510A00001C301C301DC050101DC050E01DC050601DC0528";
attribute INIT_23 of ram_1024_x_18 : label is  "0000000080016001E000C0804000E001A00001DC0518A00001DCC5C0A50FA000";
attribute INIT_24 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_25 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_26 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_27 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_28 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_29 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2A of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2B of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2C of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2D of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2E of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_2F of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_30 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_31 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_32 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_33 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_34 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_35 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_36 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_37 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_38 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_39 of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3A of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3B of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3C of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3D of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3E of ram_1024_x_18 : label is  "0000000000000000000000000000000000000000000000000000000000000000";
attribute INIT_3F of ram_1024_x_18 : label is  "4238000000000000000000000000000000000000000000000000000000000000";
attribute INITP_00 of ram_1024_x_18 : label is "4FF760DD8ED4DD83763B5348D348FFA77577775774234D23E3E22AAAA0FFFCF3";
attribute INITP_01 of ram_1024_x_18 : label is "64924934002A82CB6D70B4CCCCF333FD3F3D33AAA002AAAAEAA00D7D3C000FA3";
attribute INITP_02 of ram_1024_x_18 : label is "3976303AA2CCCF3332DA28A28A28A28A28924924924EA800AAA2D6A956AAA803";
attribute INITP_03 of ram_1024_x_18 : label is "88A3EAA3E028FAA3C0B8A38B72DCB72DCB4B3333CCCCCCCCCB333333333970B3";
attribute INITP_04 of ram_1024_x_18 : label is "000000000000000000000000000000000C82B2C2C36FCCCCF3FFCEE0AA20E383";
attribute INITP_05 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INITP_06 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";
attribute INITP_07 of ram_1024_x_18 : label is "C000000000000000000000000000000000000000000000000000000000000000";
--
begin
--
  --Instantiate the Xilinx primitive for a block RAM
  ram_1024_x_18: RAMB16_S9_S18
  --synthesis translate_off
  --INIT values repeated to define contents for functional simulation
  generic map (INIT_00 => X"E004E00301010000022601CD01CD01CD01CD019E022B0522018B022B05100215",
               INIT_01 => X"0084E000000001C3C001E0110009E0100004E10BE00AE009E008E007E006E005",
               INIT_02 => X"4B0B503920016B116A10E000A07F502320806000544520024000C080000100B4",
               INIT_03 => X"4A0550414A098A01CB01501F4B034042CA0154424A0550374A09CA018B01501F",
               INIT_04 => X"504A20806000547B20024000C080000200B40084007D401FEB11EA108A015442",
               INIT_05 => X"8B0150614B0BFAB00A094046FAB0505B4AFFCA017AB0506820016B11E000A07F",
               INIT_06 => X"FAB00A004046FAB0506E4A0A8A017AB040638B0150464B0BFAB00A006B114055",
               INIT_07 => X"2002400001C8401F007D40768B0150464B0BFAB00A096B1140688B0150744B0B",
               INIT_08 => X"0B0000A100A164156516661767186819691A6A1B011900E5A000E0000000547D",
               INIT_09 => X"00A9EB20EA1FE91EE81DE71C0700080009000A0854904B1F8B0100A1549A2A18",
               INIT_0A => X"C804C70266206A1F691E681D671CA0000A00090008000700060005000406A000",
               INIT_0B => X"650A00E240C500DF650A00DF50BE4500650B022B0512015DA000C620CA10C908",
               INIT_0C => X"01EB054D00D8020500E200D8020801EB052E00DF650900E240C500DF50C44500",
               INIT_0D => X"8530A00054D9C301C20100DF75200303A000022B8510651001EB057A01EB0548",
               INIT_0E => X"0303080109000A000B00E00FE00EE00DE00C00000209A00001EB0520A00001EB",
               INIT_0F => X"C101E00FB0B0600FE00EB0A0600EE00DB090600DE00C9080600C510141007130",
               INIT_10 => X"BA60B95098400B000A00090008060B000A00090008061480159016A017B040F1",
               INIT_11 => X"E016E017E018E019E01AE01B0000A00054F0C20183010B000A0009000806BB70",
               INIT_12 => X"E017A0846017E016806260165D3C080809080A080B0E0120680C690D6A0E6B0F",
               INIT_13 => X"601AE01B0008601BE01BA0AB601BE01AA0CC601AE019A0776019E018A0116018",
               INIT_14 => X"00086015E01600086016E01700086017E01800086018E01900086019E01A0008",
               INIT_15 => X"054E022B0520A0005525C101E01200086012E01300086013E01400086014E015",
               INIT_16 => X"000E000E1200A000017E602001EB053D01EB054400E20184071F01EB053D01EB",
               INIT_17 => X"1530016DA000803A8007597CC00AA00012000179A00F102013000179000E000E",
               INIT_18 => X"056501EB057201EB05464185B000C601C701017E70700604A00001EB152001EB",
               INIT_19 => X"01EB0547A00001EB057901EB056301EB056E01EB056501EB057501EB057101EB",
               INIT_1A => X"01EB057201EB056F01EB057401EB056101EB057201EB056501EB056E01EB0565",
               INIT_1B => X"01BA0128A00055BBC001000BA00001EB053201EB052E01EB053101EB057600E2",
               INIT_1C => X"C40101C80432A00055C9C30101C30314A00055C4C20101BE0219A00055BFC101",
               INIT_1D => X"01D8C408A4F01450A00001D2C440A4F8A000C440E40101BAC440E401A00055CE",
               INIT_1E => X"01D2C440C40CA4F01450A000C44004F001BE01D80406040604060407145001BA",
               INIT_1F => X"C440E401C440040EA000C44004F001BE01D2C4400406040604070407145001BA",
               INIT_20 => X"000E000E000E000EA5F0C440E401400101BAC440E40101BAC440E401450101BA",
               INIT_21 => X"01BE01D8042001BE01D801C301D801C801D8043001C8A00001BEC4400404D500",
               INIT_22 => X"01DCC580A50F52312510A00001C301C301DC050101DC050E01DC050601DC0528",
               INIT_23 => X"0000000080016001E000C0804000E001A00001DC0518A00001DCC5C0A50FA000",
               INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
               INIT_3F => X"4238000000000000000000000000000000000000000000000000000000000000",    
               INITP_00 => X"4FF760DD8ED4DD83763B5348D348FFA77577775774234D23E3E22AAAA0FFFCF3",
               INITP_01 => X"64924934002A82CB6D70B4CCCCF333FD3F3D33AAA002AAAAEAA00D7D3C000FA3",
               INITP_02 => X"3976303AA2CCCF3332DA28A28A28A28A28924924924EA800AAA2D6A956AAA803",
               INITP_03 => X"88A3EAA3E028FAA3C0B8A38B72DCB72DCB4B3333CCCCCCCCCB333333333970B3",
               INITP_04 => X"000000000000000000000000000000000C82B2C2C36FCCCCF3FFCEE0AA20E383",
               INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
               INITP_07 => X"C000000000000000000000000000000000000000000000000000000000000000")
  --synthesis translate_on
  port map(    DIB => "0000000000000000",
              DIPB => "00",
               ENB => '1',
               WEB => '0',
              SSRB => '0',
              CLKB => clk,
             ADDRB => address,
               DOB => instruction(15 downto 0),
              DOPB => instruction(17 downto 16),
               DIA => jdata,
              DIPA => jparity,
               ENA => sel1,
               WEA => '1',
              SSRA => '0',
              CLKA => update,
              ADDRA=> jaddr,
               DOA => doa(7 downto 0),
              DOPA => dopa); 
--  v2_bscan: BSCAN_VIRTEX2 
--  port map(   TDO1 => tdo1,
--         TDO2 => tdo2,
--            UPDATE => update,
--             SHIFT => shift,
--             RESET => reset,
--               TDI => tdi,
--              SEL1 => sel1,
--             DRCK1 => drck1,
--              SEL2 => sel2,
--             DRCK2 => drck2,
--      CAPTURE => capture);
  --buffer signal used as a clock
  upload_clock: BUFG
  port map( I => drck1,
            O => drck1_buf);
  -- Assign the reset to be active whenever the uploading subsystem is active
  proc_reset <= sel1;
  srlC1: SRLC16E
  --synthesis translate_off
  generic map (INIT => X"0000")
  --synthesis translate_on
  port map(   D => tdi,
             CE => '1',
            CLK => drck1_buf,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '1',
              Q => jaddr(10),
            Q15 => jaddr(8));
  flop1: FD
  port map ( D => jaddr(10),
             Q => jaddr(9),
             C => drck1_buf);
  srlC2: SRLC16E
  --synthesis translate_off
  generic map (INIT => X"0000")
  --synthesis translate_on
  port map(   D => jaddr(8),
             CE => '1',
            CLK => drck1_buf,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '1',
              Q => jaddr(7),
            Q15 => tap5);
  flop2: FD
  port map ( D => jaddr(7),
             Q => jaddr(6),
             C => drck1_buf);
  srlC3: SRLC16E
  --synthesis translate_off
  generic map (INIT => X"0000")
  --synthesis translate_on
  port map(   D => tap5,
             CE => '1',
            CLK => drck1_buf,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '1',
              Q => jaddr(5),
            Q15 => jaddr(3));
  flop3: FD
  port map ( D => jaddr(5),
             Q => jaddr(4),
             C => drck1_buf);
  srlC4: SRLC16E
  --synthesis translate_off
  generic map (INIT => X"0000")
  --synthesis translate_on
  port map(   D => jaddr(3),
             CE => '1',
            CLK => drck1_buf,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '1',
              Q => jaddr(2),
            Q15 => tap11);
  flop4: FD
  port map ( D => jaddr(2),
             Q => jaddr(1),
             C => drck1_buf);
  srlC5: SRLC16E
  --synthesis translate_off
  generic map (INIT => X"0000")
  --synthesis translate_on
  port map(   D => tap11,
             CE => '1',
            CLK => drck1_buf,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '1',
              Q => jaddr(0),
            Q15 => jdata(7));
  flop5: FD
  port map ( D => jaddr(0),
             Q => jparity(0),
             C => drck1_buf);
  srlC6: SRLC16E
  --synthesis translate_off
  generic map (INIT => X"0000")
  --synthesis translate_on
  port map(   D => jdata(7),
             CE => '1',
            CLK => drck1_buf,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '1',
              Q => jdata(6),
            Q15 => tap17);
  flop6: FD
  port map ( D => jdata(6),
             Q => jdata(5),
             C => drck1_buf);
  srlC7: SRLC16E
  --synthesis translate_off
  generic map (INIT => X"0000")
  --synthesis translate_on
  port map(   D => tap17,
             CE => '1',
            CLK => drck1_buf,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '1',
              Q => jdata(4),
            Q15 => jdata(2));
  flop7: FD
  port map ( D => jdata(4),
             Q => jdata(3),
             C => drck1_buf);
  srlC8: SRLC16E
  --synthesis translate_off
  generic map (INIT => X"0000")
  --synthesis translate_on
  port map(   D => jdata(2),
             CE => '1',
            CLK => drck1_buf,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '1',
              Q => jdata(1),
            Q15 => tdo1);
  flop8: FD
  port map ( D => jdata(1),
             Q => jdata(0),
             C => drck1_buf);
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- END OF FILE fg_ctrl.vhd
--
------------------------------------------------------------------------------------
