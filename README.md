# UART Transmitter & Receiver (FPGA Design)

## 📖 Overview
This project implements a **UART (Universal Asynchronous Receiver/Transmitter)** on FPGA.  
The design supports configurable baud rate and standard UART frame format (start bit, data bits, parity, stop bit).  
RTL was written in Verilog, verified with waveform simulations in QuestaSim, and synthesized/implemented in Vivado with timing closure and error-free linting.

## ⚙️ Features
- Configurable baud rate generator  
- UART Transmitter (TX) and Receiver (RX)  
- Supports start, data, parity, and stop bits  
- Handles idle and busy states correctly  
- Verified with testbench simulations  

## 🛠️ Tools & Technologies
- **Language:** Verilog HDL  
- **Simulation:** QuestaSim (functional verification, waveform analysis)  
- **Synthesis/Implementation:** Vivado (timing, utilization, schematic)  
- **Target Device:** Xilinx FPGA (xc7a200tffg1156-3)  

## 🚀 Deliverables
- RTL & Testbench code  
- Simulation waveforms (TX/RX operation)     
- Linting results (no errors)  

## 🖥️ Simulation & Results
Below are some snippets from simulation and implementation:  
![Waveform](https://github.com/Khaled15102002/UART/blob/main/UART_Waveform.jpg)  
![Schematic](https://github.com/Khaled15102002/UART/blob/main/UART.jpg)  
 


