# A Library for Peano Arithmetic


We hope the reader will learn the following techniques (labeled as **T.1**, **T.2**, etc) from this lesson:
- [**T.1**](#advanced-injection-functions) Defining injection functions for value constructors of user variant types, using module functors
  `Fmap`, `Fmap2`, `Fmap3`, etc., which are provided by the module [Logic](../../Installation/ocanren/src/core/Logic.mli).
- [**T.2**](#reification-and-reifiers) Defining reifiers to convert data from the injected level to the logic level,
  again with help from the module functors  `Fmap`, `Fmap2`, `Fmap3`, etc.
  - [**T.2.1**](#overwriting-the-show-function) Overwriting, or redefining the "show" function for values of a logic type,
    to allow for more concise and human readable printing of them.
- [**T.3**](#relations-on-peano-numbers) Defining (possibly recursive) relations, e.g.,  comparison, addition and division on Peano numbers.
- [**T.4**](#scrutinizing-relations) Making queries to the defined relations in various ways, i.e., with various numbers
  of unknown arguments. 
- [**T.5**](#analyzing-the-search-behaviour) Analyzing how, in the context of a query, a relation searches for answers.
  - [**T.5.1**](#modifying-the-search-behaviour) Reordering the conjuncts and disjuncts within the body of a relation definition
    to modify the way in which the relation searches for answers in a given query.
- [**T.6**](#the-formula-parser) Observing, how the `ocanren {}` quotation converts its content (which is a formula) into
  an expression built with names  provided by the module [Core](../../Installation/ocanren/src/core/Core.mli).
     - [**T.6.1**](#ocanren-terms) Additionally, observing how the `ocanren {}` quotation replaces  value constructors
     of variant types by the corresponding injection functions, and primitive values by their
     injected versions.
- [**T.7**](#building-a-library) Writing and testing a library in OCanren.

The techniques are presented in detail in sections below, to which the labels are linked.
An extra section concludes the lesson. 

## Advanced Injection Functions

## Reification and Reifiers

### Overwriting the _show_ function

## Relations on Peano Numbers

## Scrutinizing Relations

## Analyzing the Search Behaviour

### Modifying the search behaviour

## The Formula Parser

### OCanren Terms

## Building a Library