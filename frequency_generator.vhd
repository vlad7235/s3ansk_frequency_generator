--
-- Reference design - Frequency Generator for the Spartan-3E Starter Kit.
--
-- Ken Chapman - Xilinx Ltd - 12th July 2006
--
--
--  *** This design contains an evaluation test feature of the DCM.   ****
--  *** Before this design can be processed a special BITGEN option   ****
--  *** needs to be set. Please read the notes provided in the design ****
--  *** documentation or read the comments in this file for details   ****
--  *** of this special requirement.                                  ****
--
--
-- Provides a frequency generator with resolution of 1Hz up to a maximum frequency of 
-- approximately 100MHz (with internal 200MHz clocks). The controller is deliberately supports 
-- higher frequencies so that you can experiment with finding the limits of the Spartan device 
-- fitted to your board.
--
-- The 50MHz on board oscillator is used as the basic reference for a Direct Digital Synthesis (DDS)
-- circuit which synthesizes frequencies in the range 6.25MHz to 12.5MHz. This is then multiplied up 
-- by a DCM using a special mode to reduce the cycle to cycle jitter content that is present in the 
-- synthesized waveform. Finally a counter and multiplexer are used to divide down to the desired 
-- output frequency.
-- 
-- PicoBlaze is used to provide a human interface in which the rotary knob and LCD display are 
-- used to set the frequency required. PicoBlaze also performs some very high precision calculations 
-- in order to generate the required control values for the DDS circuit.
--
-- LEDs are used to indicate status and what would a design be without an LED flashing?
--
------------------------------------------------------------------------------------
--
-- NOTICE:
--
-- Copyright Xilinx, Inc. 2006.   This code may be contain portions patented by other 
-- third parties.  By providing this core as one possible implementation of a standard,
-- Xilinx is making no representation that the provided implementation of this standard 
-- is free from any claims of infringement by any third party.  Xilinx expressly 
-- disclaims any warranty with respect to the adequacy of the implementation, including 
-- but not limited to any warranty or representation that the implementation is free 
-- from claims of any third party.  Furthermore, Xilinx is providing this core as a 
-- courtesy to you and suggests that you contact all third parties to obtain the 
-- necessary rights to use this implementation.
--
------------------------------------------------------------------------------------
--
-- Library declarations
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
------------------------------------------------------------------------------------
--
--
entity frequency_generator is
    Port (         sma_out : out std_logic;
                    simple : out std_logic_vector(12 downto 9);
                       led : out std_logic_vector(7 downto 0);
--            strataflash_oe : out std_logic;
--            strataflash_ce : out std_logic;
--            strataflash_we : out std_logic;
                     lcd_d : inout std_logic_vector(7 downto 4);
					  lcd_dblow : out std_logic_vector(3 downto 0);
                    lcd_rs : out std_logic;
                    lcd_rw : out std_logic;
                     lcd_e : out std_logic;
                  rotary_a : in std_logic;
                  rotary_b : in std_logic;
              rotary_press : in std_logic;
                       clk : in std_logic);
    end frequency_generator;
--
------------------------------------------------------------------------------------
--
-- Start of test architecture
--
architecture Behavioral of frequency_generator is
--
------------------------------------------------------------------------------------
--
-- declaration of KCPSM3
--
  component kcpsm3 
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of program ROM
--
  component fg_ctrl
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
             proc_reset : out std_logic;                       --JTAG Loader version
                    clk : in std_logic);
    end component;
--
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
signal  address          : std_logic_vector(9 downto 0);
signal  instruction      : std_logic_vector(17 downto 0);
signal  port_id          : std_logic_vector(7 downto 0);
signal  out_port         : std_logic_vector(7 downto 0);
signal  in_port          : std_logic_vector(7 downto 0);
signal  write_strobe     : std_logic;
signal  read_strobe      : std_logic;
signal  interrupt        : std_logic :='0';
signal  interrupt_ack    : std_logic;
signal  kcpsm3_reset     : std_logic;
--
--
-- Signals for LCD operation
--
-- Tri-state output requires internal signals
-- 'lcd_drive' is used to differentiate between LCD and StrataFLASH communications 
-- which share the same data bits.
--
signal    lcd_rw_control : std_logic;
signal   lcd_output_data : std_logic_vector(7 downto 4);
signal         lcd_drive : std_logic;
--
--
-- Signals used to interface to rotary encoder
--
signal       rotary_a_in : std_logic;
signal       rotary_b_in : std_logic;
signal   rotary_press_in : std_logic;
signal         rotary_in : std_logic_vector(1 downto 0);
signal         rotary_q1 : std_logic;
signal         rotary_q2 : std_logic;
signal   delay_rotary_q1 : std_logic;
signal      rotary_event : std_logic;
signal       rotary_left : std_logic;
--
--
-- Signals used to form DDS circuit
--
signal        clk_200mhz : std_logic;
signal           dds_clk : std_logic;
signal  dds_control_word : std_logic_vector (31 downto 0);
signal  dds_scaling_word : std_logic_vector (4 downto 0);
--
signal phase_accumulator : std_logic_vector (31 downto 0);
signal   dcm_clean_clock : std_logic;
signal         synth_clk : std_logic;
--
signal frequency_divider : std_logic_vector (31 downto 0);
signal     frequency_out : std_logic;
signal     freq_out_pipe : std_logic;
--
--

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Disable unused components  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --StrataFLASH must be disabled to prevent it conflicting with the LCD display (only for S3E SK)
  --
--  strataflash_oe <= '1';
--  strataflash_ce <= '1';
--  strataflash_we <= '1';
  -- Low LCD data bits should be HIGH in 4bit mode (only for S3AN SK)  
  lcd_dblow <= "1111";
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 and the program memory 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  processor: kcpsm3
    port map(      address => address,
               instruction => instruction,
                   port_id => port_id,
              write_strobe => write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     reset => kcpsm3_reset,
                       clk => clk);
 
  program_rom: fg_ctrl
    port map(      address => address,
               instruction => instruction,
                proc_reset => kcpsm3_reset,                       --JTAG Loader version 
                       clk => clk);

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interrupt 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- Interrupt is used to detect rotation of the rotary encoder.
  -- It is anticipated that the processor will respond to interrupts at a far higher 
  -- rate that the rotary control can be operated and hence events will not be missed. 
  --

  interrupt_control: process(clk)
  begin
    if clk'event and clk='1' then

      -- processor interrupt waits for an acknowledgement
      if interrupt_ack='1' then
         interrupt <= '0';
        elsif rotary_event='1' then
         interrupt <= '1';
        else
         interrupt <= interrupt;
      end if;

    end if; 
  end process interrupt_control;

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- The inputs connect via a pipelined multiplexer
  --

  input_ports: process(clk)
  begin
    if clk'event and clk='1' then

      case port_id(0) is

        -- read rotary control signals at address 00 hex
        when '0' =>    in_port <=  "000000" & rotary_press_in & rotary_left ;

        -- read LCD data at address 01 hex
        when '1' =>    in_port <= lcd_d & "0000";

        -- Don't care used for all other addresses to ensure minimum logic implementation
        when others =>    in_port <= "XXXXXXXX";  

      end case;

     end if;

  end process input_ports;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  -- adding the output registers to the processor
   
  output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if write_strobe='1' then

        -- Write to LEDs at address 80 hex.

        if port_id(7)='1' then
          led <= out_port;
        end if;

        -- LCD data output and controls at address 40 hex.

        if port_id(6)='1' then
          lcd_output_data <= out_port(7 downto 4);
          lcd_drive <= out_port(3);  
          lcd_rs <= out_port(2);
          lcd_rw_control <= out_port(1);
          lcd_e <= out_port(0);
        end if;

        -- Write DDS frequency scaling word at addresses 20 hex.

        if port_id(5)='1' then
          dds_scaling_word <= out_port(4 downto 0);
        end if;

        -- Write 32-bit DDS control word at addresses 02, 04, 08 and 10 hex.

        if port_id(4)='1' then
          dds_control_word(31 downto 24) <= out_port;
        end if;

        if port_id(3)='1' then
          dds_control_word(23 downto 16) <= out_port;
        end if;

        if port_id(2)='1' then
          dds_control_word(15 downto 8) <= out_port;
        end if;

        if port_id(1)='1' then
          dds_control_word(7 downto 0) <= out_port;
        end if;

      end if;

    end if; 

  end process output_ports;

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- LCD interface  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- The 4-bit data port is bidirectional.
  -- lcd_rw is '1' for read and '0' for write 
  -- lcd_drive is like a master enable signal which prevents either the 
  -- FPGA outputs or the LCD display driving the data lines.
  --
  --Control of read and write signal
  lcd_rw <= lcd_rw_control and lcd_drive;

  --use read/write control to enable output buffers.
  lcd_d <= lcd_output_data when (lcd_rw_control='0' and lcd_drive='1') else "ZZZZ";

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interface to rotary encoder.
  -- Detection of movement and direction.
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- The rotary switch contacts are filtered using their offset (one-hot) style to  
  -- clean them. Circuit concept by Peter Alfke.
  -- Note that the clock rate is fast compared with the switch rate.

  rotary_filter: process(clk)
  begin
    if clk'event and clk='1' then

      --Synchronise inputs to clock domain using flip-flops in input/output blocks.
      rotary_a_in <= rotary_a;
      rotary_b_in <= rotary_b;
      rotary_press_in <= rotary_press;

      --concatinate rotary input signals to form vector for case construct.
      rotary_in <= rotary_b_in & rotary_a_in;

      case rotary_in is

        when "00" => rotary_q1 <= '0';         
                     rotary_q2 <= rotary_q2;
 
        when "01" => rotary_q1 <= rotary_q1;
                     rotary_q2 <= '0';

        when "10" => rotary_q1 <= rotary_q1;
                     rotary_q2 <= '1';

        when "11" => rotary_q1 <= '1';
                     rotary_q2 <= rotary_q2; 

        when others => rotary_q1 <= rotary_q1; 
                       rotary_q2 <= rotary_q2; 
      end case;

    end if;
  end process rotary_filter;
  --
  -- The rising edges of 'rotary_q1' indicate that a rotation has occurred and the 
  -- state of 'rotary_q2' at that time will indicate the direction. 
  --
  direction: process(clk)
  begin
    if clk'event and clk='1' then

      delay_rotary_q1 <= rotary_q1;
      if rotary_q1='1' and delay_rotary_q1='0' then
        rotary_event <= '1';
        rotary_left <= rotary_q2;
       else
        rotary_event <= '0';
        rotary_left <= rotary_left;
      end if;

    end if;
  end process direction;
  --
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Direct Digital Synthesizer (DDS)
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- The heart of the DDS is the phase accumulator. This accumulator is provided with 
  -- a control word by PicoBlaze which is accumulates every clock cycle such that the  
  -- most significant bit toggles at a required frequency. Note that this output will have 
  -- a cycle to cycle jitter equal to the rate at which the phase accumulator is clocked.
  -- The only exception to this are the few cases where control word is such that the 
  -- output is a perfect square wave (equal number of cycles High and Low). In order to 
  -- minimise this cycle to cycle jitter, the phase accumulator is clocked as fast as
  -- possible. In this case the 50MHz clock on the board is multiplied by 4 to give 
  -- a 200MHz reference resulting in 5ns of jitter. 


  --
  -- Multiply 50MHz clock by 4 to form fast 200MHz clock for phase accumulator.
  --

  phase_acc_dcm: DCM
  generic map(  CLK_FEEDBACK => "NONE",
                CLKFX_DIVIDE => 1,
              CLKFX_MULTIPLY => 4,
                CLKIN_PERIOD => 20.0) 
  port map (    CLKFX => clk_200mhz,
                CLKFB => '0',
                CLKIN => clk,
                DSSEN => '0',
                PSCLK => '0',
                 PSEN => '0',
             PSINCDEC => '0',
                  RST => '0');

  --
  -- Buffer 200MHz clock for use by phase accumulator.
  --

  buffer_dds_clk: BUFG
  port map( I => clk_200mhz,
            O => dds_clk);


  phase_acc: process(dds_clk)
  begin
    if dds_clk'event and dds_clk='1' then

      phase_accumulator <= phase_accumulator + dds_control_word;

    end if;
  end process phase_acc;



  --
  -- The most significant bit of the phase accumulator 'phase_accumulator(31)' is the 
  -- numerically synthesized frequency but will have cycle to cycle jitter of 5ns 
  -- due to the 200MHz clock. 
  --
  -- Since 5ns of jitter is smaller in percentage terms when synthesizing lower frequencies,
  -- the output from the phase accumulator is deliberately kept relatively low (<12.5MHz) and  
  -- then a second DCM used to multiply this to the higher rates (x16).
  --
  -- However, the DCM does not normally like the 5ns cycle to cycle jitter because it is 
  -- designed to maintain phase alignment. So in this case the DCM is used in a special 
  -- 'frequency aligned mode' in which the DCM output will reflect the average frequency of 
  -- input and deliberately ignore phase alignment. This will result in a cycle to cycle jitter 
  -- which is typically much less than 300ps which is an incredible improvement over 5ns.
  --
  -- Of course you an not get something for nothing! When using the frequency aligned mode, the 
  -- DCM output will vary slightly in frequency as it 'tracks' the average of the input. This is just 
  -- like a control loop used to position a platform. The feedback gain of such a control loop will 
  -- result in different responses. A high gain feedback will result in the smallest positional error
  -- overall but the rapid movements can be unpleasant and damaging. In many ways a DCM which is 
  -- locked to the phase of a waveform is doing exactly this. A low gain feedback will provide 
  -- smooth adjustments that can feel much more comfortable but the slower reaction will allow greater 
  -- errors to accumulate before being corrected each time. This is how the DCM is behaving in 
  -- in frequency aligned mode.
  --
  -- To use the DCM in frequency aligned mode starts with inserting the DCM primitive in your design 
  -- the same way as it would normally be used. Obviously we use the CLKFX output and there is no
  -- point providing any feedback as phase alignment is being deliberately deactivated.
  --  
  -- In this design the DCM is required to multiply the clock by 16 as well as provide the 
  -- frequency aligned mode to reduce the cycle to cycle jitter.
  --

  frequency_aligned_dcm: DCM
  generic map(  CLK_FEEDBACK => "NONE",
                CLKFX_DIVIDE => 1,           -- CLKFX factors are shown but will be overwritten
              CLKFX_MULTIPLY => 16,        
                CLKIN_PERIOD => 80.0) 
  port map (    CLKFX => dcm_clean_clock,
                CLKFB => '0',
                CLKIN => phase_accumulator(31),
                DSSEN => '0',
                PSCLK => '0',
                 PSEN => '0',
             PSINCDEC => '0',
                  RST => '0');

  --
  -- Then to activate the frequency aligned mode a special option must be applied to BITGEN when 
  -- processing the design with the ISE tools.....
  --
  --  Inside Project Navigator go to the 'processes' window
  --    right click 'Generate Programming File'
  --      Properties
  --        General Options
  --           Then add the following text string into the 'Other Bitgen Command Line Options' box
  --
  --      -g cfg_dfs_s_x1y1:1111000011111111xxx111xxxxx1xxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx01000000
  --
  -- You will also notice that the UCF file supplied with this design has a constraint which places
  -- this DCM into a known position (INST "frequency_aligned_dcm" LOC=DCM_X1Y1;) and it is that 
  -- position which is referenced by the 'x1y1' part of the text string.
  -- 
  -- There are a few other key parts to the text string for those that wish to experiment further.
  -- To see these it helps to segment the line temporarily as follows...
  --
  --                        D-1      M-1                                                           C-1
  --  -g cfg_dfs_s_x1y1: 11110000 11111111 xxx111xxxxx1xxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx 01000000
  --
  -- You can see that the line contains three 8-bit values. These directly set the CLKFX_DIVIDE, 
  -- CLKFX_MULTIPLY values along with something we will call 'CCount'. The multiply and divide values 
  -- are exactly the same as those normally set using the parameters on the DCM primitives but require 
  -- a little bit of effort to set this way!
  --
  -- For CLKFX_MULTIPLY = 256
  --   M-1 = 255 = 11111111 binary. Then reverse the bit order and you still get 11111111.
  --
  -- For CLKFX_DIVIDE = 16
  --   D-1 = 15 = 00001111 binary. Then reverse the bit order to get 11110000.
  --
  -- You will notice that the CLKFX factors have been set to 256/16 to multiply the clock by 16 rather 
  -- than the normal 16/1. This is because the averaging effect (damping) is related to the CLKFX_MULTIPLY 
  -- value. The larger CLKFX_MULTIPLY is, then the smoother the output frequency and lower the cycle to 
  -- cycle jitter. Normally you are restricted to a value of 32 or less because large values would be 
  -- detrimental to the ability to phase lock to a signal but here we need to achieve the opposite.
  --
  -- Which is where the 'CCount' value comes in. This is formed in the same way....
  -- 
  -- For CCount = 3
  --   C-1 = 2 = 00000010 binary. Then reverse the bit order to get 01000000.
  -- 
  -- 'CCount' is related to how many cycles are received between updates to the output. So again this   
  -- is a form of damping control. In fact the damping effect is therefore related to the value of 
  -- CCOUNT x CLKFX_MULTIPLY. The larger this product the more stable the output will be but the greater
  -- the accumulated error can be before it corrects itself.
  --
  -- In practice, the largest product 256 x256 = 65536 has such a damping effect that if used in this application
  -- it takes several seconds per mega-Hertz for the output to change frequency as new setting are applied. Large 
  -- frequency changes would be very slow to achieve which is often inconvenient. However, a large value of 
  -- CCount would often be the best setting if using the generator as a clock source that is not adjusted
  -- once set. Using lower values of CCount with large value of CLKFX_MULTIPLY allows fairly rapid changes to 
  -- the frequency to be made (when turning the knob) but still provides a reasonably stable output frequency 
  -- with low cycle to cycle jitter.  
  --



  --
  -- Create new clock domain for the clean synthesized clock using a global buffer.
  --

  buffer_synth_clk: BUFG
  port map( I => dcm_clean_clock,
            O => synth_clk);


  --
  -- The synthesized clock covers a high frequency range 100 to 200MHz. The final output is 
  -- achieved by dividing this by multiples of 2 using a simple counter and multiplexer structure.
  --

  freq_scaling: process(synth_clk)
  begin
    if synth_clk'event and synth_clk='1' then

      frequency_divider <= frequency_divider + 1;


      case dds_scaling_word is

        when "00000" =>      frequency_out <= frequency_divider(0);    -- 50MHz and above output
        when "00001" =>      frequency_out <= frequency_divider(1);    -- 25MHz to 50MHz output  
        when "00010" =>      frequency_out <= frequency_divider(2);    -- 12.5MHz to 25MHz output
        when "00011" =>      frequency_out <= frequency_divider(3);    -- etc...
        when "00100" =>      frequency_out <= frequency_divider(4);
        when "00101" =>      frequency_out <= frequency_divider(5);
        when "00110" =>      frequency_out <= frequency_divider(6);
        when "00111" =>      frequency_out <= frequency_divider(7);
        when "01000" =>      frequency_out <= frequency_divider(8);
        when "01001" =>      frequency_out <= frequency_divider(9);
        when "01010" =>      frequency_out <= frequency_divider(10);
        when "01011" =>      frequency_out <= frequency_divider(11);
        when "01100" =>      frequency_out <= frequency_divider(12);
        when "01101" =>      frequency_out <= frequency_divider(13);
        when "01110" =>      frequency_out <= frequency_divider(14);
        when "01111" =>      frequency_out <= frequency_divider(15);
        when "10000" =>      frequency_out <= frequency_divider(16);
        when "10001" =>      frequency_out <= frequency_divider(17);
        when "10010" =>      frequency_out <= frequency_divider(18);
        when "10011" =>      frequency_out <= frequency_divider(19);
        when "10100" =>      frequency_out <= frequency_divider(20);
        when "10101" =>      frequency_out <= frequency_divider(21);
        when "10110" =>      frequency_out <= frequency_divider(22);
        when "10111" =>      frequency_out <= frequency_divider(23);
        when "11000" =>      frequency_out <= frequency_divider(24);
        when "11001" =>      frequency_out <= frequency_divider(25);
        when "11010" =>      frequency_out <= frequency_divider(26);  -- 1Hz output
        when "11011" =>      frequency_out <= frequency_divider(27);
        when "11100" =>      frequency_out <= frequency_divider(28);
        when "11101" =>      frequency_out <= frequency_divider(29);
        when "11110" =>      frequency_out <= frequency_divider(30);
        when "11111" =>      frequency_out <= frequency_divider(31);

        -- Don't care used for all other to ensure minimum logic implementation
        when others =>    frequency_out <= 'X';  

      end case;
 
      -- Pipeline output from multiplexer to maintain performance up to 200MHz

      freq_out_pipe <= frequency_out;   
      sma_out <= freq_out_pipe;

    end if;
  end process freq_scaling;

  --
  -- Test points 
  --
 
  simple(9) <= phase_accumulator(31);
  simple(10) <= '0';
  simple(11) <= '0';
  simple(12) <= freq_out_pipe;

  --
  --
  --
end Behavioral;

------------------------------------------------------------------------------------------------------------------------------------
--
-- END OF FILE frequency_generator.vhd
--
------------------------------------------------------------------------------------------------------------------------------------

