# PASMath - Mathematical Expression Evaluator

**pasmath.pas**

**Version:** 0.06a (Alpha)

**Author:** Michele Povigna

**Date:** code first posted on *it.comp.lang.pascal* on Dec 26, 2001.

## Overview
PASMath is an alpha version of a mathematical expression evaluator designed to numerically evaluate expressions and display the step-by-step calculations. The current version (0.06a) is the first "public" release, featuring basic functionality for addition and subtraction. The interface is minimal, represented by a prompt 'Pas>'.

## Features
- Supports basic arithmetic operations: addition and subtraction.
- Numerically evaluates expressions and displays intermediate steps.
- Inspired by the UMS - Universal Math Solver (at https://universalmathsolver.com/) but aims to provide an open source alternative.
- Future plans include expanding functionality to support more operations and parentheses.

## Known Issues
- Limited functionality in the alpha version.
- Interface is rudimentary with only a prompt.
- Some issues may be attributed to either the code or the compiler (currently using TP 7.0).

## Example Output
```
Pas> 37+4+9+-12-5+27-5+22+12-59
37+4+9+-12-5+27-5+22+12-59
41+9+-12-5+27-5+22+12-59
50+-12-5+27-5+22+12-59
50-12-5+27-5+22+12-59
38-5+27-5+22+12-59
33+27-5+22+12-59
60-5+22+12-59
55+22+12-59
77+12-59
89-59
30
```

## License
This software is free and comes with ABSOLUTELY NO WARRANTY.

## Notes
- The source code is approximately sixty lines, though it may appear convoluted.
- The parser implementation is a work in progress and may have deficiencies.
- Current focus on implementing additional operations and parentheses.

Feel free to explore the source code and provide feedback. Contributions are welcome!
