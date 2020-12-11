# FIFO-with-Data-Width-Conversion

## Description

In some applications, the widths of the write port and read port of a FIFO buffer may not be the
same. For example, a subsystem may write 16-bit data into the FIFO buffer and another
subsystem only reads and removes 8-bit data at a time. Assume that the width of the write port is
twice the width of the read port. Redesign the FIFO with a modified controller and register file
and verify its operation. The DATA_WIDTH generic parameter should be the width of the read port.
