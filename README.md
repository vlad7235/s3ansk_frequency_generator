# Spartan-3AN Starter Kit frequency generator

This is a modifiation of the frequency generator project for another board, Spartan-3E Starter Kit,
PicoBlaze Processor Frequency Generator in https://www.xilinx.com/products/boards/s3estarter/reference_designs.htm .

User constraints file and top level VHDL module are changed w.r.t. Spartan-3AN SK board.

### Prerequisites

Download Xilinx PicoBlaze files for Spartan-3 device family from https://www.xilinx.com/ipcenter/processor_central/picoblaze/member/KCPSM3.zip (registration required),
extract kcpsm3.vhd

### Creating ISE project

Create new ISE 14.7 project for the Spartan-3AN Starting Kit board. Add the following files to the project:

```
fg_ctrl.vhd
frequency_generator.vhd
frequency_generator.ucf
kcpsm3.vhd
```
Run synthesis, create a bitfile and program FPGA with iMPACT.

### Testing generator

The current frequency is indicated on LCD, to change it use rotary knob. Check the description
https://www.xilinx.com/products/boards/s3estarter/files/s3esk_frequency_generator.pdf






