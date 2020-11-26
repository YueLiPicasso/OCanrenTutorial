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
- Defining injection functions for value constructors of user variant types, using module functors
  `Fmap`, `Fmap2`, `Fmap3`, etc., which are provided by the module [Logic](../../Installation/ocanren/src/core/Logic.mli).   
- Defining reifiers to convert data from the injected level to the logic level,
  again with help from the module functors  `Fmap`, `Fmap2`, `Fmap3`, etc.
  - Overwriting, or redefining the "show" function for values of a logic type,
    to allow for more concise and human readable printing of them.
- Defining (possibly recursive) relations on Peano numbers.
- Making queries to the defined relations in various ways, i.e., with various numbers
  of unknowns. 
- Analyzing how, in the context of a query, a relation searches for answers.
  - Reordering the conjuncts and disjuncts within the body of a relation definition
    to modify the way in which the relation searches for answers in a given query.
- Observing how the `ocanren {}` quotation converts its content (which is a formula) into
  an expression built with names  provided by the module [Core](../../Installation/ocanren/src/core/Core.mli).
     - Optionally, how the quotation replaces the value constructors by corresponding
  injection functions to build injected values.