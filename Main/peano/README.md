# A Library for Peano Arithmetic


We hope the reader will learn the following techniques from this lesson:
- Defining injection functions for value constructors of user variant types, using module functors
  `Fmap`, `Fmap2`, `Fmap3`, etc., which are provided by the module [Logic](../../Installation/ocanren/src/core/Logic.mli).  ... [Go](#advanced-injection-functions)
- Defining reifiers to convert data from the injected level to the logic level,
  again with help from the module functors  `Fmap`, `Fmap2`, `Fmap3`, etc.
  - Overwriting, or redefining the "show" function for values of a logic type,
    to allow for more concise and human readable printing of them.
- Defining (possibly recursive) relations, e.g.,  comparison, addition and division on Peano numbers.
- Making queries to the defined relations in various ways, i.e., with various numbers
  of unknown arguments. 
- Analyzing how, in the context of a query, a relation searches for answers.
  - Reordering the conjuncts and disjuncts within the body of a relation definition
    to modify the way in which the relation searches for answers in a given query.
- Observing, how the `ocanren {}` quotation converts its content (which is a formula) into
  an expression built with names  provided by the module [Core](../../Installation/ocanren/src/core/Core.mli).
     - Additionally, observing how the `ocanren {}` quotation replaces  value constructors
     of variant types by the corresponding injection functions, and primitive values by their
     injected versions.
- Writing and testing a library in OCanren.

The above techniques are presented in detail in the following sections, followed by a conclusion.

## Advanced Injection Functions

## Reification and Reifiers

### Overwriting the _show_ function

## Relations on Peano Numbers

## Scrutinizing Relations

## Analyzing the Search Behavour

### Modifying the search behaviour

## The Formula Parser

### OCanren Terms