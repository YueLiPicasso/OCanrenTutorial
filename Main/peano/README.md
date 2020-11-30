# A Library for Peano Arithmetic


We hope the reader will learn the following techniques (labeled as **T.1**, **T.2**, etc) from this lesson:
- [**T.1**](#advanced-injection-functions) Defining injection functions for value constructors of  variant types, using
  the Fmap family of module functors
  `Fmap`, `Fmap2`, `Fmap3`, etc., which are provided by the module [Logic](../../Installation/ocanren/src/core/Logic.mli).
- [**T.2**](#reification-and-reifiers) Defining reifiers to convert data from the injected level to the logic level,
  again with help from the Fmap family of module functors.
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

The primary injection operator is `!!` which is used to cast primitive values (such as characters and strings)
and constant constructors of variant types (particularly whose type constructors do not have a type parameter)
from the ground level to the injected level. For those variant types  whose type constructors have
one or more type parameters, the primitive injection operator is inadequate. We use instead _advanced injection
functions_ to build injected values,  which are defined using distribution functions provided
by the Fmap family of module functors together with the injection helper `inj`, all from the
module Logic. In our Peano Arithmetic [library implementation](peano.ml), the following block of code defines advanced injection
functions `o` and `s` for the abstract Peano number type `Ty.t`, which correspond respectively to the value constructors `O` and `S`:
```ocaml
module Ty = struct
  @type 'a t = O | S of 'a with show, gmap;;
  let fmap = fun f d -> GT.gmap(t) f d;;
end;;
  
include Ty;;

module F = Fmap(Ty);;

let o = fun () -> inj @@ F.distrib O;;
let s = fun n  -> inj @@ F.distrib (S n);;
```
The general workflow of defining advanced injection functions is as follows:  

1. We begin with a variant type whose type constructor `t` has one or more type parameters. This is always an
  OCanren abstract type, such as the abstract Peano number type or the abstract list type.
1. We count the number of type parameters of the type constructor in order to choose the suitable module functor
  from the Fmap family: for one type parameter, use `Fmap`; for two type parameters, use `Fmap2`; three type parameters, `Fmap3`
   and so on.
1. We request the `gmap` plugin for the type constructor, and use it to define a function named `fmap` simply by renaming.
1. We put the definitions of the type constructor `t` and the `fmap` function in one module, and suppy that module as
   a parameter to the chosen Fmap family module functor. The result is a module `F` with three functions one of which
   is `distrib`, the distribution function.
1. For each value constructor of the type `t`, we define a function whose name is the same as the value constructor except
   that the initial letter is set to lower case. For example, `Cons`, `S` and `NUL` become respectively `cons`, `s` and `nUL`.
   - For each value constructor `Constr0` of no argument, define:
     ```ocaml
     let constr0 = fun () -> Logic.inj @@ F.distrib Constr0
     ```
   - For each value constructor `Constr1` of one argument, define:
     ```ocaml
     let constr1 = fun x -> Logic.inj @@ F.distrib (Constr1 x)
     ```
   - For each value constructor `Constru` of _u_ (> 1) arguments, define:
     ```ocaml
     let constru = fun x1 ... xu -> Logic.inj @@ F.distrib @@ Constru (x1, ..., xu)
     ```
In the definition of a typical advanced injection function, the value constructor takes arguments which are at the injected level, and the combination
of `inj` and `distrib` serves to inject the top level value while preserving the structure of constructor application. If we explain by a schematic
where a pair of enclosing square brackets `[]` signifies the injected status of the enclosed data, we would say that:
- An advanced injection function `constr` converts a value of the form  `Constr ([arg1], ..., [argn])` to a value of the form `[Constr (arg1, ..., argn)]`.
  In other words,
- The injection function  `constr` takes arguments `[arg1], ..., [argn]` and builds a value of the form `[Constr (arg1, ..., argn)]`.

We advise the reader
to find in the [interface](../../Installation/ocanren/src/core/Logic.mli) of the Logic module the Fmap module functor family
and the module types of arguments of members of this family: that would provide a more formal explanation of what advanced injection functions do and
why they are defined in the given manner.

## Reification and Reifiers

Say we have a logic variable `x` and a substitution `[(x, Lam(z,y));(y, App(a,b))]` that associates `x` with the term `Lam(z,y)` and `y` with `App(a,b)` where
`y, z` are also logic variables. We would like to know what `x` is with respect to the substitution. It is straightforward to replace `x` by `Lam(z,y)` but since
`y` is associated with `App(a,b)` we can further replace `y` in `Lam(z,y)`, and finally we get the term `Lam(z,App(a,b))`. Although there is still an unbound part
`z`, we have no further information about how `z` might be instantiated, so we leave it there. What we have done is called _reification_ of the logic
variable `x`: we instantiate it as much as possible, but allowing unbound logic variables to occur in the result. A _reifier_ is a function that reifies logic variables.


We know that there are primary and advanced injection functions. Similarly there are primary and advanced reifiers: the primary reifier `Logic.reify` reifies logic
variables over base types (like character and string) and simple variant types (i.e., those that have only constant constructors). Advanced reifiers
are for logic variables over variant types whose type constructors have one or more type parameters and there exist non-constant (value) constructors.
The Peano Arithmetic library defines an advanced reifier for the
Peano number type:
```ocaml
let rec reify = fun env n -> F.reify reify env n;;
```
Advanced reifiers are defined using the Fmap module functor family. The correct Fmap module functor for defining the reifier for a type is the same as that selected for
defining advanced injection functions for the same type.  The result of applying the correct Fmap module functor is a module that provides, besides a distribution
function, a reifier builder named `reify`, e.g., `F.reify` in the case of our library. Note there is an abuse of names: the name `reify` has been used for both reifiers
and reifier builders. If a type constructor takes other types are parameters, then the refier for the top level type is built from reifiers for the parameter types:
we build "larger" reifiers from "smaller" reifiers. The Peano number reifier is recursive because the Peano number type is recursive. The reader should refer to
the [signature](../../Installation/ocanren/src/core/Logic.mli#L136) of `F.reify` and see how the types of the reifier and the reifier
 builder fit together.


## Overwriting the _show_ Function

The default _show_ function for a variant type converts values of that type
to strings in a straightforward way, e.g., a logic Peano number
representation of the integer 1 would be converted to the string `"Value(S(Value O))"`
whilst "the successor of some unknown number" could be  `"Value(S(Var(1,[])))"`. These
are not too readble. The Logic module has already [redefined](../../Installation/ocanren/src/core/Logic.ml#L35) the _show_ function for the
type `Logic.logic` so that the above values would be converted to strings `"S(O)"` and `"S(_.1)"`
respectively.

## Relations on Peano Numbers

## Scrutinizing Relations

## Analyzing the Search Behaviour

## Modifying the Search Behaviour

## The Formula Parser

## OCanren Terms

## Building a Library

## Conclusion