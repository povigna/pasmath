# PASMath - Mathematical Expression Evaluator

**pasmath.pas**

**Version:** 0.27 beta

**Authors:** Michele Povigna, Carmelo Spiccia

**Date:** First posted on *it.comp.lang.pascal* on Jan 27, 2002.

## Overview
PASMath, version 0.27 beta, is a mathematical expression evaluator designed for basic arithmetic operations. This program is distributed under the terms of the GPL (Gnu Public License), copyright (C) 2001 Michele Povigna, Carmelo Spiccia, with ABSOLUTELY NO WARRANTY.

### Recent Updates
- Resolved several bugs, including some severe ones.
- Improved expression visualization.
- Added support for the factorial operator (!); note that there's currently no check for the positivity and integer requirement of the factorial operand.
- Experimental support for absolute value and implicit products.
- Compiled successfully with Turbo Pascal and FreePascal, despite the presence of the directive $N, indispensable for TP.

Please test it when you have some time.

**Note:** This update introduces version 0.27 beta and includes bug fixes, new features, and compatibility with Turbo Pascal and FreePascal.

## Features
- Supports basic arithmetic operations: addition, subtraction, multiplication, division, and exponentiation.
- Numerically evaluates expressions and displays intermediate steps.
- Improved handling of the positive sign in the second operand.
- Corrected handling of null results in individual operations.
- Added support for parentheses in expressions.
- Handles division by zero and the indeterminate form `0^0`.
- Supports the factorial operator (!).
- Experimental support for absolute value and implicit products.

## License
This program is distributed under the terms of the GPL - Gnu Public License. Copyright (C) 2001 Michele Povigna, Carmelo Spiccia. This program comes with ABSOLUTELY NO WARRANTY.

## Usage
1. Run the program.
2. Enter mathematical expressions at the 'PAS>' prompt.
3. To exit the program, type 'QUIT'.

## Code Details
- The source code is provided under the GPL license.
- Supports basic arithmetic operations, exponentiation, and now handles division by zero, `0^0`, and factorial (!).
- Improved handling of the positive sign in the second operand.
- Corrected handling of null results in individual operations.
- Added support for parentheses in expressions.
- Experimental support for absolute value and implicit products.
- The program includes a 'QUIT' command to exit.

Feel free to explore the source code, provide feedback, and contribute!

---

**Note from Carmelo:**
This new version supports absolute value, has fewer bugs, and has been successfully compiled with both Turbo Pascal and FreePascal (despite the presence of the directive $N, indispensable for TP). It has not undergone significant changes compared to the previous version, although, in my opinion, it is quite better than the latter. I plan to add support for implicit products in the next version, such as "3!4!(4-2)!". Ciao, Carmelo.
