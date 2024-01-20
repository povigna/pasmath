# PAS Math

A simple calculator program written in Pascal.

## Overview

Despite the version number, the latest PAS Math release includes additional code (31 KB compared to the previous 21 KB). The improvements mainly focus on the interface, introducing colored expressions and the ability to recall previously entered input using the UP and DOWN arrow keys. Other enhancements include better handling of implicit products, partial resolution of the issue with calculating roots of negative numbers (complete resolution requires implementing fractions to avoid rounding in the exponent), and improved support for scientific notation (a fictitious overflow is reported when exceeding the 35th digit). Additionally, a command to disable expression colors has been added.

The next planned steps involve adding real support for exponential notation and fractions.

Ciao, Carmelo.

## License

This source code is distributed under the terms of the GPL - GNU Public License.

Copyright (C) 2001 Michele Povigna, Carmelo Spiccia.

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You can find a copy of this license at [http://www.gnu.org/licenses/gpl.txt](http://www.gnu.org/licenses/gpl.txt).

## Usage

Compile and run the program using Pascal. The code includes a simple calculator with various features.

### Commands

- **QUIT**: Exits the program.
- **COLOR**: Displays the current status of expression colors (ON or OFF).
- **COLOR ON/OFF**: Enables or disables expression colors.
- **DELAY**: Displays the current status of the delay feature (ON or OFF).
- **DELAY ON/OFF**: Enables or disables the delay feature.
- **DELAY <milliseconds>**: Sets the delay time in milliseconds.

### Example

COLOR OFF
DELAY ON

### Development
The program is written in Pascal. For development or contribution, please follow the guidelines outlined in the source code.

Note: This README provides a general overview and usage instructions. Refer to the source code comments and documentation for more detailed information.
