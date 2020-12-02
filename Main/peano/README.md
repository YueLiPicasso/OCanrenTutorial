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
- [**T.5**](#analyzing-the-search-behaviour) Analyzing why a query returns certain answers.
  - [**T.5.1**](#modifying-the-search-behaviour) Reordering the conjuncts and disjuncts within the body of a relation definition
    to modify the way in which the relation searches for answers in a given query.
- [**T.6**](#the-formula-parser) Observing, how the `ocanren {}` quotation converts its content (which is a formula) into
  an expression built with names  provided by the module [Core](../../Installation/ocanren/src/core/Core.mli).
     - [**T.6.1**](#ocanren-terms) Additionally, observing how the `ocanren {}` quotation replaces  value constructors
     of variant types by the corresponding injection functions, and primitive values by their
     injected versions.
- [**T.7**](#building-a-library) Writing and testing a library in OCanren.

The techniques are presented in detail in sections below, to which the labels ( **T.1**, **T.2**, etc) are linked. Each
section is self-contained and could be read independent of other sections.

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
are not too readable.

The Logic module has already [redefined](../../Installation/ocanren/src/core/Logic.ml#L35) the _show_ function for the
type `Logic.logic` so that the above values would be converted to strings `"S(O)"` and `"S(_.1)"`
respectively, omitting the verbose constructors `Value` and `Var` and displaying variables in the form `_.n` where `n` is the first
parameter of the constructor `Var`. The redefinition happens within the record value `logic` which has a field `GT.plugins`. This record value origins from the
`@type` definition of the type constructor `Logic.logic` and is auto-generated by the GT package. The field `GT.plugins` is an object with
severa methods, one of which is `show` whose default definition is, like other plugins:
```ocaml
method show = logic.GT.plugins#show
```
and whose default behaviour is the starightforward string conversion mentioned above.

However, when there are too many repetitions of the constructor `S`, the
_show_ function as redefined in the Logic module is no longer suitable. Our Peano Arithmetic library therefore offers a further customized [redefinition](peano.ml#L105)
just for displaying logic Peano numbers, converting
those values without free variables directly to Arabic numbers and those with free variables a sum between an Arabic number and the symbol `n`.


In like manner, the reader may:
- Redefine the _show_ function to behave in other ways, or
- Redefine other plugins by modifying the `GT.plugins` field, or
- Redefine plugins for other types.

Some additional remarks on the last point: the `@type` definition of a type constructor `typeconstr-name` generates a record value also named `typeconstr-name` of the type `GT.t`.
This could be viewed by adding the `-i` option as indicated in the [Makefile](Makefile#L10):
```
BFLAGS = -rectypes -g -i
``` 
See also the [GT source](https://github.com/JetBrains-Research/GT/blob/039193385e6cb1a67bc8a9d00c662d9d1dc5478b/src/GT.ml4#L37).


## Relations on Peano Numbers

This section teaches the reader how to read
and write relation definitions.

The reader is already familiar with reading and writing functions in OCaml. To read a function, just look at the type annotation (if any)
to determine what are the input types and what is the output type, and then inspect the function body to see how the inputs are
processed to produce the output. To write a function, first decide the type of the function, and then design the internal procedure
that produces the output from the input.

In OCanren, a relation is a function only at the language implementation level, and as users our experience with functions
do not transfer well when it comes to reading and writing relations. That's why relational programming claims the status of
 being a unique programming paradigm distinct from imperative programming and functional programming. Working with  relations requires
learning a new way of thinking: _declarative_ thinking.


Relation definitions are declarative, meaning that it first of all states a proposition. The emphasize is on "what" rather
than "how". It is the language implementation that takes care of "how", but the user of the language should foucs on "what".
For example,
look at the addition relation:
```ocaml
let rec add a b c =
  ocanren{ a == O & b == c
         | fresh n, m in
           a == S n & c == S m & add n b m};;
```
It says nothing about how to compute the sum `c` of two numbers `a` and `b`, instead it only says what conditions must be
satisfied so that the addition relation exists among the three numbers `a`, `b` and `c` --- if `a` equals
`O` and `b`  equals `c`, or, if `a` equals `S n` and `c` equals `S m` and the numbers `n,b,m` also satisfy the addition
relation, for some `n,m`.  No other way is given in which we can establish the addition relation among three numbers.

Another example is the "less than" relation:
```ocaml
let rec lt a b =
  ocanren{ fresh n in
           b == S n &
             { a == O
             | fresh n' in
               a == S n'
               & lt n' n }};;
```
It says that `a` is less than `b` if there exist `n`, such that `b` equals `S n`, and either `a` equals `O` or there exist `n'`
such that `a` equals `S n'` and `n'` is less than `n`.

Other relations in the library shall be
read in this way, and they are all written with the declarative reading in mind. The reader is
encouraged to write a relation for subtraction: `sub a b c` iff `a - b = c`, or,
put in another way: iff `b` is `O` and `a` is `c`, or `b` is `S n` and `a` is `S n'`
and `sub n' n c`.  


## Scrutinizing Relations

Taking the "less than" relation as an example, we can ask questions like:
- Is zero less than one ? Is one less than two ? Is one less than zero ? Is two less than one?
- What is less than five ? Five is less than what ?
- What is less than what ?

 The first set of questions above is for _checking_:
we provide concrete numbers and ask if they satisfy the relation. The remaining two sets of
questions are for _searching_: looking for numbers that satisfy the relation. Note that
the questions are organized: there coud be no unknown, 
one unknown or two unknowns, and each argument position of the relation might be an unknown.
In general, for a relation of N arguments, the total number of kinds of questions we can ask is
( R is the number of unknowns in <sub>N</sub>C<sub>R</sub>):

<sub>N</sub>C<sub>0</sub> + <sub>N</sub>C<sub>1</sub> + <sub>N</sub>C<sub>2</sub> + ... + <sub>N</sub>C<sub>N-1</sub> + <sub>N</sub>C<sub>N</sub>

Running the [test](test.ml#L44)  shows that OCanren answers all the questions well. For example, the goal:
```ocaml
fun q -> ocanren { lt O (S O) & lt (S O) (S(S O)) } 
```
asks about what is `q` so that  zero is less than one and  one is less than two, and the answer
is just `n` meaning that `q` could be any number and the relation always holds among the given
numbers. The similar goal:
```ocaml
fun q -> ocanren { lt (S O) O | lt (S(S O)) (S O) }
```
asks about what is `q` so that one is less than zero or two is less than one. There is
no answer, meaning that there is no `q` to make the relation hold among the given numbers.


The goal below asks what is less than five:
```ocaml
fun q -> ocanren { lt q (S(S(S(S(S O))))) }
```
For this goal the answers `0,1,2,3,4` are found, which is quite satisfactory.

The relations `lte, add, div, gcd` are also questioned systematically in the test file.

Note that the addition relation can perform subtraction, and the division
relation can do multiplication. For instance, the goal below
asks "What adds 4 equals to 7 ?" and whose answer is "3":
```ocaml
fun q -> ocanren { add q (S(S(S(S O)))) (S(S(S(S(S(S(S O))))))) }
```
This amounts to performing the subtraction `7 - 4`.  The next goal asks "What divided by 5 equals 3 with remainder 0 ?" and the answer is "15":
```ocaml
fun q -> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) O }
```
It amounts to the multiplication `3 * 5`.


## Analyzing the Search Behaviour

When asking the `lt` relation "what is less than 5" using the goal:
```ocaml
fun q -> ocanren { lt q (S(S(S(S(S O))))) }
```
OCanren returns 0,1,2,3,4. Let's see why. It really is a matter of definition:
we defined `lt a b` to be a certain formula and now we substitute 5 for  `b` in the
formula `lt a b` followed by several steps of simplification then
we get a formula that literally says `a` shall be 0, 1, 2, 3 or 4. Below are the
details.

We reproduce the definition of `lt`
in the followinig simplified form:
```
lt a b = fresh n in b == S n & { a == O | fresh n' in a == S n' & lt n' n } (Eq.1)
```
Now replace `b` by `(S(S(S(S(S O)))))` in `(Eq.1)`, we get:
```
lt a (S(S(S(S(S O))))) = fresh n in (S(S(S(S(S O))))) == S n
        & { a == O | fresh n' in a == S n' & lt n' n }                      (Eq.2)
```
Replace `(S(S(S(S(S O))))) == S n` by `(S(S(S(S O)))) == n`  in `(Eq.2)`, we get:
```
lt a (S(S(S(S(S O))))) = fresh n in (S(S(S(S O)))) == n
        & { a == O | fresh n' in a == S n' & lt n' n }                      (Eq.3)
```
In `(Eq.3)`, remove `fresh n in (S(S(S(S O)))) == n`, then replace all occurences of `n`
by `(S(S(S(S O))))`. The top level `&` and the braces are no longer needed, so also being
removed. We get:
```
lt a (S(S(S(S(S O))))) =  a == O
                       |  fresh n' in a == S n' & lt n' (S(S(S(S O))))      (Eq.4)
```
Now replace `b` by `(S(S(S(S O))))` and`a`
by `n'` in `(Eq.1)` in a capture-avoiding manner, we get:
```
lt n' (S(S(S(S O)))) = fresh n in (S(S(S(S O)))) == S n
                    & { n' == O | fresh n'' in n' == S n'' & lt n'' n }     (Eq.5)
```
Similar to the way `(Eq.2)` is simplified into `(Eq.4)`, we can transform `(Eq.5)` into:
```
lt n' (S(S(S(S O)))) =  n' == O
                     |  fresh n'' in n' == S n'' & lt n'' (S(S(S O)))       (Eq.6)
```
Now in `(Eq.4)` replace `lt n' (S(S(S(S O))))` by the right hand side of `(Eq.6)`:
```
lt a (S(S(S(S(S O))))) =  a == O
                       |  fresh n'  in
		          a == S n' &
			    { n' == O
                            |  fresh n'' in
			       n' == S n'' & lt n'' (S(S(S O))) }

                                                                             (Eq.7)
```
In `(Eq.7)`, distribute `a == S n'` we get:
```
lt a (S(S(S(S(S O))))) =  a == O
                       |  fresh n'  in
		          a == S n' &  n' == O
                          |  a == S n' &  fresh n'' in
				           n' == S n'' & lt n'' (S(S(S O)))
						     
						                             (Eq.8)
```
Replace `n'` by `O` and remove all parts rendered unnecessary by this move in `(Eq.8)`, we get:
```
lt a (S(S(S(S(S O))))) =  a == O
                       |  fresh n'  in
		          a == S O 
                          |  a == S n'
		             &  fresh n'' in  n' == S n''
			     & lt n'' (S(S(S O)))                            (Eq.8)
```
Restructure the right hand side of `(Eq.8)` we have:
```
lt a (S(S(S(S(S O))))) =  a == O
                       |  a == S O
		       |  fresh n'  in  a == S n'
		          &  fresh n'' in  n' == S n'' & lt n'' (S(S(S O)))  (Eq.9)
```
The last but one state of such transformation is:
```
lt a (S(S(S(S(S O))))) =  a == O
                       |  a == S O
		       |  a == S (S O)
		       |  a == S (S (S O))
		       |  a == S (S (S (S O)))
		       |  fresh n'    in a == S n'
		          &  fresh n'' in n' == S n''
			  &  fresh n''' in n'' == S n'''
			  &  fresh n'''' in n''' == S n''''
			  &  fresh n''''' in n'''' == S n''''' & lt n''''' O
			                                                     (Eq.10)
```
Note that `lt n''''' O` expands to `fresh n in O == S n & ...` which is false, therefore the
last state of the transformation is:
```
lt a (S(S(S(S(S O))))) =  a == O
                       |  a == S O
		       |  a == S (S O)
		       |  a == S (S (S O))
		       |  a == S (S (S (S O)))                               (Eq.11)
```
From `(Eq.11)` we read off the answers to the query.


## Modifying the Search Behaviour

## The Formula Parser

## OCanren Terms

## Building a Library

## Conclusion