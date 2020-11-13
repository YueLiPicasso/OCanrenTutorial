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

We will use the above structure summary as the guideline of our narrative.

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
where _n_ ranges from 0 to 10 inclusive, and the tuple _(c, n, s)_ satisfy the
relation _ascii_ctrl_.

OCanren will answer: "_s_ could be any one of the following strings,"
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
 of the program that did this automatically.

## The Semantics of the Language

Relational programming languages have two semantics: the _declarational semantics_ and the
_operational semantics_. The way above in which the reader is advised to read the relation
definition and the query is actually part of the declarational semantics.
The operational semantics concerns how the answers shall be searched for (mechanically), which
is part of the implementation of the language. For example, the operational
semantics of the relational language [Prolog](https://www.swi-prolog.org/) is called
_SLD-resolution_, or in the long form "*L*inear *resolution* for *D*efinite clauses with a 
*S*election function". The operational semantics of OCanren is a set of stream manipulation
rules attached to the logic connectives (`&` for "and", `|` for "or", `fresh` for "exist")
and basic relations (`==` for "unify", `=/=` for "not unify"). Both operational semantics
mentioned exhibit the behaviour called "backtracking" that allows exploration of alternative
rules during the search for answers. We explain the operational semantics of OCanren in more
detail below.

### Goals and Logic Connectives as Stream Processors 


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


