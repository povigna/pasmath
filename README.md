# PASMath - Mathematical Expression Evaluator

**pasmath.pas**

**Version:** 0.24 alpha 1

**Authors:** Michele Povigna, Carmelo Spiccia

**Date:** First posted on *it.comp.lang.pascal* on Jan 5, 2002.

## Overview
PASMath, version 0.24 alpha 1, is a mathematical expression evaluator designed for basic arithmetic operations. This program is distributed under the terms of the GPL (Gnu Public License), copyright (C) 2001 Michele Povigna, Carmelo Spiccia, with ABSOLUTELY NO WARRANTY.

### Recent Updates
- Added support for parentheses in expressions.
- Addressed known bugs:
  1. Division by zero now returns zero.
  2. Expression parsing priority issue in cases like `4/2*5` is resolved.
  3. Distinguish between `(-7)^2` and `-7^2`; they now yield different results.

Please note that, as always, your feedback and suggestions are welcome.

## Features
- Supports basic arithmetic operations: addition, subtraction, multiplication, division, and exponentiation.
- Numerically evaluates expressions and displays intermediate steps.
- Improved handling of the positive sign in the second operand.
- Corrected handling of null results in individual operations.
- Added support for parentheses in expressions.
- Write 'QUIT' to exit the program.

## License
This program is distributed under the terms of the GPL - Gnu Public License. Copyright (C) 2001 Michele Povigna, Carmelo Spiccia. This program comes with ABSOLUTELY NO WARRANTY.

## Usage
1. Run the program.
2. Enter mathematical expressions at the 'PAS>' prompt.
3. To exit the program, type 'QUIT'.

## Code Details
- The source code is provided under the GPL license.
- The program supports basic arithmetic operations and exponentiation.
- Improved handling of the positive sign in the second operand.
- Corrected handling of null results in individual operations.
- Added support for parentheses in expressions.
- The program includes a 'QUIT' command to exit.

Feel free to explore the source code, provide feedback, and contribute!
