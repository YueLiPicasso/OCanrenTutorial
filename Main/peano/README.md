# A Library for Peano Arithmetic

The files involved in this lesson are organized as follows:

- The library
  - [implementation](peano.ml)
  - [interface](peano.mli)
- [Test file](test.ml)
- Makefile
- [Result of test](answers.txt)
- [Parsing the formulae parser](ocanren_expr.md) 

There are several things which we want the reader to learn in this lesson:
- Defining injection functions for user recursive types using module functors
  `Fmap`, `Fmap2`, `Fmap3`, etc., which are provided by the module [Logic]((../../Installation/ocanren/src/core/Logic.mli).   
- Defining reifiers to convert data from the injected level to the logic level,
  again with help from the module functors  `Fmap`, `Fmap2`, `Fmap3`, etc.
  - Overwriting, or redefining the "show" function for values of a logic type,
    to allow for more concise and human readable printing of them. 