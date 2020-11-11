# A Simple Data Base

In this lesson we learn the basic form of relational programming:
defining and querying a data base. In particular, we build a toy data
base of the 32 control characters in the ASCII table, associating each
character with its integer number and description, for example: `BS`
with number 8 and description "Back space".

The [program](ASCII_Ctrl_DB.ml) is a bit long, but yet simple in the sense
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
1. The data base as a relation
1. Some queries on the data base

We will use the above structure summary as the guideline of our narrative. But before that, let us
clear the one remaining hurdle.

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
in the Makefile as explained in a comment line there. 


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

<hr>

OCaml has four types of base values:
- integer numbers
- floating-point numbers
- characters
- character strings

In OCanren, we usually do not work with floating point numbers, and integer numbers are
conventially encoded as and directly, but  

The [program](hello2.ml) that we study in this lesson is almost the
same as [the one](../helloWorld/hello.ml) of the previous lesson, except that the line:
```ocaml
let str = !!("hello world!\n");;
```
now becomes:
```ocaml
let str : String.groundi = !!("hello world!\n");;
```
where we have added a type annotation`String.groundi`, and before that we have inserted a 
 `String` module of several type definitions:
```ocaml
module String = struct
  @type t = GT.string with show;;
  @type ground = t with show;;
  @type logic = t logic' with show;;
  type groundi = (ground, logic) injected;;
end;;
```
that shows how the type `String.groundi` of `str` is defined following the four-step routine.

In the String
module, the type `t` is at the abstract level, and the type `ground` is at the ground level,
`logic` at the logic level, and `groundi` at the injected level. In our example the abstract level
and the ground level coincide, but in general they are quite different.



## The `logic` Type

The `logic` type constructor occuring on the right hand side of the type equation:
```ocaml
@type 'a logic' = 'a logic with show;;
```
is provided by the
[Logic](../../Installation/ocanren/src/core/Logic.mli#L21) module
(included in the OCanren module). To define the string type at the logic level,
we need to alias the `Logic.logic` constructor as `logic'`. This is also a piece
of OCanren boilerplate.

## Summary

All types manipulated by OCanren are at the injected level, but to define such types
we need three other kinds of types which are said to be at the
_abstract_, _ground_ and _logic_ levels. 