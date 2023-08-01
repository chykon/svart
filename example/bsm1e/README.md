# BSM-1E

## About

* Design - Socket Machine (SM, SoMa) [see [TTA](https://en.wikipedia.org/wiki/Transport_triggered_architecture), [OISC](https://en.wikipedia.org/wiki/One-instruction_set_computer)]
* Instruction set - Soma-1
* Implementation - BSM-1E (Binary Socket Machine - 1, mark E)

## Core

* Computational model - binary socket machine
* Architecture type - load-store
* Branching - compare-and-branch
* Data width - 8 bit (byte)
* Instruction:
  * width - 16 bit (halfword)
  * alignment - halfword
  * transport/operating format - `<Destination/Alpha (D/A): byte>-<Source/Omega (S/O): byte>`
  * encoding - `(LSB)[D/A, S/O](MSB)`
* Socket array index width - byte
* Signed number representation - two's complement
* Endianness - little-endian

## Memory

* Memory model - flat
* Minimum addressable unit - byte
* Memory alignment - halfword
* Address width - halfword
* Contains - instructions, data
