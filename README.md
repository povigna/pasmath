# PAS Math

## Overview

PAS Math is a mathematical expression parser and calculator written in Pascal. This program supports various mathematical operations, including exponentiation and factorial, and aims to handle large numbers without approximation.

## Changes in this Version

Important updates have been made in this new, though not extensively tested, version of PAS Math. The key enhancements include:

1. **Exponential Notation Support:** The addition of support for exponential notation allows the handling of large numbers. For example, calculations like "11^37-12^35" can now be performed.

2. **Precise Calculations:** The update ensures the absence of approximations, enabling calculations such as "2/(.0000003-.0000001)" without triggering division by zero errors.

However, it's important to note a limitation introduced by the new version: a strict limit of 255 characters per string. This limitation becomes challenging when dealing with more than 9 numbers in exponential notation. As a workaround, you can deactivate exponential notation for small numbers by setting the global constant `HighPrecision` to false.

## Feedback

Please try out the updated version and provide your feedback. Additionally, any suggestions on how to overcome the 255-character limitation (e.g., using AnsiString or Null-terminated string) would be highly appreciated.

Thank you in advance for your feedback!

Ciao, Carmelo.

---

## License

This source code is distributed under the terms of the GPL (GNU Public License). You can redistribute and modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 or any later version. For more details, refer to the [GNU General Public License](http://www.gnu.org/licenses/gpl.txt).

Copyright (C) 2001 Michele Povigna, Carmelo Spiccia.

---

## Usage

To run the program, compile the source code using a Pascal compiler and execute the resulting executable. Follow the on-screen instructions for inputting mathematical expressions and obtaining results.

---
