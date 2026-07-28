# UART with Runtime Configurable Baud Rate

## Overview

This project implements a configurable UART transmitter and receiver in Verilog HDL on an Intel Cyclone IV FPGA. Unlike a traditional UART with a fixed baud rate, this design allows the user to enter a supported baud rate using a 4×4 matrix keypad at runtime.

The entered baud rate is validated, converted into the appropriate clock divider, and used by the baud rate generator without requiring recompilation or FPGA reconfiguration.

---

## Features

- Verilog HDL implementation
- Runtime baud rate configuration
- 4×4 matrix keypad interface
- Debounced keypad input
- Configurable baud generator
- UART transmitter
- UART receiver
- Modular RTL architecture
- Individual testbenches for each module
- Quartus synthesis
- ModelSim verification

---

## Supported Baud Rates

| Baud Rate |
|-----------:|
| 9600 |
| 19200 |
| 38400 |
| 57600 |
| 115200 |

---

## Project Architecture

```
                uart_top
                    │
     ┌──────────────┴──────────────┐
     │                             │
     ▼                             ▼
 controller                    uart_tx
     │                             ▲
     │                             │
     ▼                             │
 keypad_interface                  │
     │                             │
     ▼                             │
 keypad_scanner                    │
     │                             │
     ▼                             │
 debounce                          │
     │                             │
     ▼                             │
 baud_parser                       │
     │                             │
     ▼                             │
 baud_generator ───────────────────┘

                     uart_rx
```

---

## RTL Modules

| Module | Description |
|---------|-------------|
| `keypad_scanner` | Scans the 4×4 matrix keypad and detects key presses |
| `debounce` | Removes switch bouncing and generates a single valid key pulse |
| `baud_parser` | Converts keypad digits into a supported baud rate |
| `baud_generator` | Generates baud timing ticks from the selected divider |
| `uart_tx` | UART transmitter |
| `uart_rx` | UART receiver |
| `controller` | Coordinates configuration and UART operation |
| `uart_top` | Top-level integration module |

---

## Verification

Each RTL module includes an independent ModelSim testbench.

Verification includes:

- Reset operation
- Keypad scanning
- Debounce timing
- Baud rate parsing
- Baud tick generation
- UART transmission
- UART reception
- Top-level integration

---

## FPGA Target

- Intel Cyclone IV
- Quartus Prime Lite
- ModelSim

---

## Folder Structure

```
UART/
│
├── docs/
├── tb/
├── waveforms/
├── rtl/
├── LICENSE
└── README.md
```

---

## Future Improvements

- LCD display for baud rate
- Error detection
- UART loopback demonstration
- Hardware communication with a PC terminal
- SystemVerilog implementation

---

## Skills Demonstrated

- Verilog HDL
- RTL Design
- Finite State Machines (FSM)
- UART Protocol
- Clock Division
- Digital Debouncing
- Modular Hardware Design
- ModelSim Verification
- Quartus Prime
- FPGA Implementation
