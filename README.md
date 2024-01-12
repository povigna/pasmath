# PASMath - Mathematical Expression Evaluator

**pasmath.pas**

**Version:** 0.25 beta

**Authors:** Michele Povigna, Carmelo Spiccia

**Date:** First posted on *it.comp.lang.pascal* on Jan 18, 2002.

## Overview
PASMath, version 0.25 beta, is a mathematical expression evaluator designed for basic arithmetic operations. This program is distributed under the terms of the GPL (Gnu Public License), copyright (C) 2001 Michele Povigna, Carmelo Spiccia, with ABSOLUTELY NO WARRANTY.

### Recent Updates
- Added support for parentheses in expressions.
- Addressed known bugs:
  1. Division by zero now returns zero.
  2. Expression parsing priority issue in cases like `4/2*5` is resolved.
  3. Distinguish between `(-7)^2` and `-7^2`; they now yield different results.
  4. Correctly handles division by zero and the indeterminate form `0^0`.
  5. Improved display of expressions, but some imperfections remain (e.g., "[-4]^2+5-(6)/2").

Please note that, as always, your feedback and suggestions are welcome.

## Features
- Supports basic arithmetic operations: addition, subtraction, multiplication, division, and exponentiation.
- Numerically evaluates expressions and displays intermediate steps.
- Improved handling of the positive sign in the second operand.
- Corrected handling of null results in individual operations.
- Added support for parentheses in expressions.
- Handles division by zero and the indeterminate form `0^0`.
- Write 'QUIT' to exit the program.

## License
This program is distributed under the terms of the GPL - Gnu Public License. Copyright (C) 2001 Michele Povigna, Carmelo Spiccia. This program comes with ABSOLUTELY NO WARRANTY.

## Usage
1. Run the program.
2. Enter mathematical expressions at the 'PAS>' prompt.
3. To exit the program, type 'QUIT'.

## Code Details
- The source code is provided under the GPL license.
- The program supports basic arithmetic operations, exponentiation, and now handles division by zero and `0^0`.
- Improved handling of the positive sign in the second operand.
- Corrected handling of null results in individual operations.
- Added support for parentheses in expressions.
- The program includes a 'QUIT' command to exit.

Feel free to explore the source code, provide feedback, and contribute!
