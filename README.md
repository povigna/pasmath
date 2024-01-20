# PASmath

PASmath is a Pascal-based mathematical expression parser and evaluator.

## Version 0.291 alpha

### Release Date

Released on Mar 11, 2002.

### Release Notes:

#### Changes and Additions

- Compared to the last version released twenty days ago, this version has an additional 12 KB.
- Bug Fixes and Improvements:
  1. Corrected a significant bug in handling negative signs for numbers in exponential notation. Previously, expressions like "4-2/3" did not work as expected.
  2. Added variable management using the "SET" command. The variable "ANS" now holds the result of the last calculated expression. Credit to "Il mago delle comete" for the variable implementation.
  3. Introduced the DEC command to set the number of decimal places (default is now four instead of two). Also, added the EXIT command (identical to QUIT) for convenience.
  4. Implemented a display filter for better readability. For example, input like "+000041*+00000.12000000" now appears as "41*0.12".

### Overview

This program allows you to input mathematical expressions and calculates the results. It supports basic arithmetic operations, exponentiation, parentheses, and more.

### License

This source is distributed under the terms of the GPL - GNU Public License.
Copyright (C) 2001 Michele Povigna, Carmelo Spiccia.

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You can find a copy of this license at [http://www.gnu.org/licenses/gpl.txt](http://www.gnu.org/licenses/gpl.txt).

### Usage

1. Run the program in a Pascal environment.
2. Input a mathematical expression when prompted.
3. View the result and any errors in the output.

### Contributing

Feel free to contribute to the development of this project. Fork the repository, make changes, and submit a pull request.

### Issues

If you encounter any issues or have suggestions, please open an issue.

### Disclaimer

This program comes with no warranty. Use it at your own risk.
