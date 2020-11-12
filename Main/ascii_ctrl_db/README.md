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
`-dsource` in the Makefile as explained in a comment line there. 


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

## The Injection Functions


The signature of the `ASCII_Ctrl.Inj` module shall explain itself. For every value constructor,
 an accompanying  injection function shall be defined,  whose name is the same as
the constructor name except that the first letter is set to lower case. These injection functions
are implicitly called in the `ocanren{...}` quotation wherever a value constructor occurs. Hence
the `let open ASCII_Ctrl.Inj in` statement that preceeds the body of the `ascii_ctrl` relation. 