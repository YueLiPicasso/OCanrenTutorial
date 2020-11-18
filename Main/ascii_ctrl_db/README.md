# A Simple Data Base

In this lesson we learn the basic form of relational programming:
defining and querying a data base. In particular, we build a toy data
base of the 32 control characters in the ASCII table, associating each
character with its integer number and description, for example: `BS`
with number 8 and description "Back space".

The [program](ASCII_Ctrl_DB.ml) is a bit long, yet simple in the sense
that:
- The types defined therein are not recursive: there are just a base
  type (`string`) and a variant type admitting only constant constructors.
- The relation defined therein is not recursive: it is a straightforward
  listing of the data base, which is the very basic form of relational
  programs.

The structure of the program is as follows:
1. The initial opening statement
1. Type definitions and utilities
   1. The ASCII control characters type
      - Injection utilities
   1. The logic string type
1. The data base as a relation `ascii_ctrl`
1. Some queries on the data base

## The Relation and Queries

Read the definition of `ascii_ctrl` as:
> _c_, _n_ and _s_ form the relation _ascii_ctrl_ iff  _c_ is NUL and _n_ is 0 and _s_ is the
string "Null", or  _c_ is SOH and _n_ is 1 and _s_ is the string "Start of heading", or ...,
or _c_ is US and _n_ is 31 and _s_ is the string "Unit separator".

Read the query:
```ocaml
(** Find the control characters in a given range *)
let _ =
  List.iter print_endline @@
    Stream.take ~n:18 @@ 
      run q (fun s ->
          ocanren {fresh c,n in Std.Nat.(<=) 0 n
                                & Std.Nat.(<=) n 10
                                & ascii_ctrl c n s}) project;;
```
as:
> Print at most 18 possible values of _s_, such that exist some _c_ and _n_
where _n_ ranges from 0 to 10 inclusive, and the tuple _(c, n, s)_ satisfies the
relation _ascii_ctrl_.

OCanren will print the following (eleven) strings:
```
Null
Start of heading
Start of text
End of text
End of transmission
Enquiry
Ackonwledge
Bell
Back space
Horizontal tab
Line Feed
```


We could see that the relational program specifies a relation, and it has
 been used to find missing elements of a tuple that is claimed to satisfy
 some constraint of which the relation is a part. In so doing, we did not
 tell the program _how_ to find these missing elements. It was the semantics
 of the programming language that did this automatically. We explain the syntax and
 semantics next.

## Syntax of a Formula

The notion of a formula in OCanren is different from that in logic
 programming, i.e., the Horn clause subset of first-order predicate logic.
 Instead it belongs to the system
 [μMALL](https://doi.org/10.1007/978-3-540-75560-9_9).

A formula is either atomic, or is compound and built from atomic formulae
using conjunction (`&`), disjunction (`|`) and existential quantification (`fresh`).
Atomic formulae are built from predicate  symbols followed by their arguments.
There are only two predicate symbols `==` and `=/=`.  A formula 
is allowed to be infinitely long but it shall always contain a finite
number of free logic variabes.  Formulae can be abbreviated by (possibly recurisive) definitions.

**Example.**  Atomic, compound, named and infinite formulae:
- `x == y` and  `1 =/= 2` are two atomic formulae.
- By the definition `foo x y :=  x == 1 & y =/= 2 `,  we can use `foo x y` to
  abbreviate the compound  formula ` x == 1 & y =/= 2`.
- By the recursive definition `is_nat x := x == O | fresh y in x == S y & is_nat y`
  we can use `is_nat x` to abbreviate the infinitely long formula:
  ```
  x == O
  | fresh y1 in
    x == S y1 & { y1 == O
                | fresh y2 in
                  y1 == S y2 & { y2 == O
			       | fresh y3 in
			         y2 == S y3 & { ... }}}
  ```
We now give the concrete syntax of a formula in OCanren. 

```ebnf
formula  = atomic formula
         | compound formula
	 | named formula
	 | '{', formula, '}' ;

atomic formula = value, '==', value | value, '=/=', value;

compound formula = formula, '&', formula
                 | formula, '|', formula
		 | 'fresh', lparams, 'in',  formula;

named formula = formula name, ' ', values; 

formula name definition = 'let', ['rec'], let-binding, {'and', let-binding}; 

let-binding =  formula name, [':', typexpr, '->', 'goal' ], '=',
               'fun', fparams, '->', 'ocanren','{', formula, '}' ;

lparams = param, {',', param};
fparams = param, {' ', param};
values  = value, {' ', value};
```
The scope of `fresh...in` extends as far as possible.
`&` binds tighter than `|`. A formula always has the type `goal` (this type constructor
is provided by the module Core). The braces `{}` could be used
 for explicit grouping, as in  `{ x == 1 | x == 2 } & y == 0`. 

## A Note on the Concept of a _Goal_

In logic programming, we call the formula which we want to refute a _goal_. This term (i.e., goal) is
inherited by the modern successor of logic programming, which is called _relational
programming_. However, the semantics of a _goal_ nevertheless changes: it is no longer
something that we want to refute, but something for which we want to find variable
substitutions so that it is true. In other words:
- Logic programming is proof by contradiction: we want to find variable substitutions
 so that a formula _F_ is true, but what we do is to find substitutions so that the
 negation of F is false.
- Relational programming is proof by straightforward construction without the
  logical detour of "negation of negation".



## The Semantics of a Formula

A formula has two semantics: the _declarational semantics_ and the
_operational semantics_. [The way](#the-relation-and-queries) in which the reader is advised to read the relation
definition and the query is actually part of the declarational semantics.
The operational semantics concerns how the answers shall be searched for (mechanically), which
is part of the implementation of the language.

Declaratively, the two predicate symbols `==` and `=/=` means respectively "syntactic equality"
 and "syntactic disequality". The logic connectives mean as usual, and a value just denote
 itself as a syntactic object. The operational semantics of OCanren is a set of stream
 manipulation rules attached to the logic connectives and the predicate symbols, and formulae are
 viewed as functions taking a stream member as input and returning a stream. We explain
 the operational semantics of OCanren in more detail below. Firstly the concept of a _stream_.

###  Streams


A stream is a generalization of a list: members of a list can be put on
one-on-one correspondence with members of some _finite_  subset of the natural numbers, whilst
members of a stream can be put on one-on-one correspondence with members of some
possibly infinite subset of the natural numbers. Intuitively, the imaginary, infinitely
long sequence of all natural numbers itself is an example of a stream. The sequence of
all integers `...-3 -2 -1 0 1 2 3...` or equivalently `0 1 -1 2 -2 3 -3 ...` is another. 

The set of all streams can also be defined in the more technical,  _coinductive_ manner as follows:
1. Let **FS** be an operator whose input is a set of sequences and whose output
is also a set of sequences. A sequence is said to be composed of its members drawn from a set of
possible members.
1. The output of **FS** is constructed by:
   1. Starting with an empty set, to add members to it incrementally;
   1. Adding the empty stream;
   1. Prefixing each sequence of the input set with an arbitrary member, then adding the results. 
1. The set St of all streams is the _largest_ set that is a fixed-point of **FS**, in other words,
   **FS**(St) = St and St is a superset of st for all **FS**(st) = st. 

**Example** If we restrict sequence members to integers, and let the input be `{123, 111}`,
which is the set whose  members are the sequences `123` and `111`. One possible output of **FS** operating
on the input is `{e, 0123, 5111}` where `e` is the empty stream. Another possible output is `{e,1123, 1111}`.
In neither case the output equals the input, which is quite usual. The two notable exceptions are the set
L<sub>min</sub> of all lists of integers, and the set L<sub>max</sub> of all finite and infinite
sequences of integers. They are both fixed-points of **FS**, known as the _least fixpoint_ and the _greatest fixpoint_.
 L<sub>max</sub> is also the set of all streams of integers.

Note that in a typical inductive specification we could require that the set being defined
is the samllest fixed-point. Here instead we ask for the _largest_, hence the _coinductive manner_.

### Substitution

A _substitution_ is a list of substitution components.
A _substitution component_ (for short: _component_) is a pair (_lvar_, _value_) where _lvar_ is a
logic variable.  A substitution component (_lvar_, _value_)
can be _applied_ to some value _value<sub>pre</sub>_, so that all occurrences
 of _lvar_ in _value<sub>pre</sub>_ are simultaneously replaced by _value_, and the
 result is another value _value<sub>post</sub>_. A component is _applicable_ if
 applying it would make a difference. 
To apply a substitution is to repeatedly apply its components
until none is applicable. 

**Example** Applying `[(x, Cons(1,y));(y, Cons(2,z));(z, Nil)]` to `Cons(0,x)`
results in: `Cons(0,Cons(1,Cons(2,Nil)))`.


### Formulae as Stream Builders


Whatever the construction of a formula, it is always a
stream builder as far as the operational semantics is concerned: it takes a
substitution _subst<sub>in</sub>_ as input and returns a stream of substitutions as output.
For each substitution _subst<sub>out</sub>_ in the returned stream,
applying the concatenation _subst<sub>in</sub> ^ subst<sub>out</sub>_  makes the formula
 true in the sense of the declarational semantics.

**Example.** Given as input the empty  substitution `[]`:
- The relation `x == Cons(1,Nil)` returns the stream that consists of
  the substitution `[(x, Cons(1,Nil))]`.
- The relation `x == Cons(1,Nil) & y == Cons(2,x)` returns the stream
  that consists of the substitution `[(x, Cons(1,Nil));(y, Cons(2,x))]`.
- The relation `is_nat x`  returns the stream
  that consists of the substitutions `[(x, O)]`, `[(x, S(y1));(y1, O)]`,
  `[(x, S(y1));(y1, S(y2));(y2, O)]`, ...
- The relation `1 == 1` returns the stream whose only member is `[]`.
- The relation `1 == 2` returns the empty stream: there is no way to make the
  relation hold.

In summary,  we take a functional view of a relation: _not_ as a function from the
set of arguments to the set of booleans, but as a function
from the set of substitutions to the set of streams of substitutions. Formally, not



 but
 
subst<sub>in</sub> ---> _R(arg<sub>1</sub>, ..., arg<sub>n</sub>)_ --->  subst<sub>out</sub>, subst<sub>out</sub>, subst<sub>out</sub>, ...

### Disjunction as a Stream Zipper

To _zip_ two streams means to merge them by interleaving their members.

**Example.** Let _s_<sub>1</sub> denote the stream of all positive intergers,
and _s_<sub>2</sub> the stream of all negative intergers. The result of
zipping _s_<sub>1</sub> with _s_<sub>2</sub>,  denoted _s_<sub>1</sub> |<sub>zip</sub> _s_<sub>2</sub> , is `1, -1, 2, -2, ... ` or `-1, 1, -2, 2, ...`. 

The disjunction _R_<sub>1</sub> `|` _R_<sub>2</sub> of two relations
_R_<sub>1</sub>, _R_<sub>2</sub> is itself a relation on the top level, so it is
 a stream builder, taking a substitution as input and returns a stream of
 substitutions. It builds the output stream by zipping the two streams built
 separately by _R_<sub>1</sub> and _R_<sub>2</sub>, both of which share the
 same input as their immediate top level relation. In more formal terms:

`(` _R_<sub>1</sub> `|` _R_<sub>2</sub> `)` subst<sub>in</sub> = 
`(` _R_<sub>1</sub> subst<sub>in</sub> `)` |<sub>zip</sub> `(` _R_<sub>2</sub> subst<sub>in</sub> `)`  

### Conjuction as a Stream Map-Zipper

### A Recursively Defined  Relation Builds a Lazy Stream 

## The @type Syntax

In OCanren, type constructors are often defined by :
```ebnf
type definition = '@type', typedef, 'with', plugins

plugins = plugin { ',' , plugin }

plugin  ::= 'show' | 'gmap' | etc
```
where the syntactic category `typedef` is the same as
[that](https://ocaml.org/releases/4.11/htmlman/typedecl.html) of OCaml, and the category `etc` signifies omission:
the most frequently used plugins in OCanren are _show_ and _gmap_, providing for the defined type a string converson function
(like [Stdlib.string_of_int](https://ocaml.org/releases/4.11/htmlman/libref/Stdlib.html)) and
a structure preserving map function 
(a generalization of  [List.map](https://ocaml.org/releases/4.11/htmlman/libref/List.html))  respectively. The other less used
plugins are not shown here.


A type definition of the form `@type <typedef> with <plugins>` is expanded at the syntactic level
by GT into:
1) A type definition of the usual form `type <typedef>`, where the value of `<typedef>` is preserved, and
1) Several (auto-generated) plugin definitions.

The effect of syntactic transformation, including what the `@type`
definitions become after expansion, can be viewed by adding the "dump source" option
`-dsource` in the Makefile as explained in a comment line there. For instance, the `LString`
 module:
```ocaml 
 (** {2  The logic string type} *)
module LString = struct
  @type t = GT.string with show;;
  @type ground = t with show;;
  @type logic = t OCanren.logic with show;;
  type groundi = (ground, logic) injected;;
end;;
```
would be expanded into [this](lstring.ml), where we could see that besides the type
 constructor definitions a lot more codes have actually been auto-generated to
 support the  requested  `show` plugins. 


## The Type Definitions

The module `ASCII_Ctrl`  defines types following the four-level
framework: abstract, ground, logic and injected. Although
it takes about thirty lines to enumerate all the control character names,
the mathematical nature of these definitions are simple: even simpler than
the types of logic lists and Peano numbers which we learnt previously.
For instance, since the type is non-recursive and the constructors have
no argument, the abstract form of the type coincides with the ground form.

The sub-module `ASCII_Ctrl.Inj` is discussed in the next section.

The `LString` module defines types of strings in four levels, where
the abstract type and ground type also coincide. Worth noting that
the type constructor name `string` is qualified by the module name `GT`,
for we need to use the GT version of the string type which provides the
useful plugins and otherwise it is the same as the OCaml built-in string type.
Plugins are (auto-)created inductively: GT provides plugins for base types and
rules for building plugins for compound types from component types. 

## The Injection Functions and the `ocanren{...}` Quotation

The signature of the `ASCII_Ctrl.Inj` module shall explain itself. For every value constructor,
 an accompanying  injection function shall be defined,  whose name is the same as
the constructor name except that the first letter is set to lower case.
In the `ocanren{...}` quotation,
wherever a value constructor occurs, its corresponding
injection function is implicitly called. Hence
the `let open ASCII_Ctrl.Inj in` statement that preceeds the body of the `ascii_ctrl` relation.
The quotation in the body of `ascii_ctrl` is expanded as follows:

```ocaml
let ascii_ctrl =
  (fun c ->
     fun n ->
       fun s ->
         let open ASCII_Ctrl.Inj in
           OCanren.disj
             (OCanren.conj (OCanren.unify c (nUL ()))
                (OCanren.conj (OCanren.unify n (OCanren.Std.nat 0))
                   (OCanren.unify s (OCanren.inj (OCanren.lift "Null")))))
             (OCanren.disj
                (OCanren.conj (OCanren.unify c (sOH ()))
                   (OCanren.conj (OCanren.unify n (OCanren.Std.nat 1))
                      (OCanren.unify s
                         (OCanren.inj (OCanren.lift "Start of heading")))))
                (OCanren.disj
                   (OCanren.conj (OCanren.unify c (sTX ()))
                      (OCanren.conj (OCanren.unify n (OCanren.Std.nat 2))
                         (OCanren.unify s
                            (OCanren.inj (OCanren.lift "Start of text")))))
(* ... etc *)			    

```
The above code excerpt is also from what is displayed on the terminal after
compiling the source with the "dump source" option `-dsource`.


## A Note on the Term "Relation"

In the language of set theory, a relation is essentially a function from the
set of arguments to the set of booleans. For logicians, a relation symbol is
known as a predicate symbol, and by supplying a relation symbol with (all of)
its arguments we get an atomic formula. Furthermore, atomic formulae are used
to build (compound) formulae with logic connectives.

As a consequence, the way we think about a relation changes as well. In logic
 programing and set theory when we think about a relation, we are actually thinking about
 a function _R_ that can be applied to its arguments and return either true or false, like this:

_R(arg<sub>1</sub>, ..., arg<sub>n</sub>)_ = true | false

But in relational programming, when we think about a relation _R_, the most important thing
is not that _R_ is a function, but _R(arg<sub>1</sub>, ..., arg<sub>n</sub>)_ _in whole_ is a function.
In other words, we regard what is known by logicians as a formula, as a function.  View this way,
a formula F is a also a function F, whose input is an initial variable substitution and whose output is
the set of all possible variable substitutions where each member when combined with the initial substitution
makes F true. In this sense, a formula with free variables defines a relation on these same variabes.

Now the reader might say:  we cannot talk about the truth of a formula without mentioning interpretations
of the symbols in the formula. 

For the above account, a formula with free variables defines a relation on these same variabes.
This is the reason that we call such a formula, with the restricted syntax and the interpretation so required,
a _relation_ and regard our new notion of a relation as a function that manipulates
substitutions. A generalization would include formulae without free variables: for example:
the formula `1 == 1 & 2 == 2` defines a relation that is true for any argument.  