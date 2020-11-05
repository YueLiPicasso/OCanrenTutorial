# Digesting the Types 

OCanren is for typed relational programming.Two points here: it is typed, and it is relational.
We shall now study how to work with the types. This clears the way so that we
can then focus on the relational part.

We have seen that the OCanren internal representation of a string has a type of the form
`('a, 'a logic) injected` and we have named it an _injected type_, referring to the injection
of data from user level representation into the internal representation. This type expression
involves several sutlties that are, when
combined together, not apparent. In this lesson we break down such type expressions into
their very components, so that the reader can appreciate the construction of these internal types
and can build his own. 

## Abstract Types

First  we need a notion of _abstract type_. OCaml also has a notion of abstract type
which refers to a type constructor whose equation and representation are hidden from the user and is
considered incompatible with any other type. However, the abstract type that we are talking about here
is a different concept, and it comes from the fact that some recurive types can be defined in the following way.
Say we want to define a polymorphic list type:
```ocaml
module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b 
end;;
```
The type constructor `MyList.t` is called an abstract list type for it not only abstracts over the list memeber type
 by means of the type parameter `'a`,  but also abstracts over the list tail type or in other words over the list type
 itself  by means of the type parameter `'b`. 

## Ground Types

The usual definition of the recursive list type can then be decomposed into the two finer steps:
1. Abstraction over self `(* 1 *)`.
1. Instantiation by self followed by an additional equation to close the loop `(* 2 *)`.
See below:
```ocaml
module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b   (* 1 *)
  type 'a ground = ('a, 'a ground) t        (* 2 *)
end;;
```
If you substitute `'b` with `'a ground` in equation `(* 1 *)`, you would get (literally):
```
type ('a, 'a ground) t = Nil | Cons of 'a * 'a ground  (* 1b *)
```
Then by `(* 1b *)` and `(* 2 *)` we have:
```ocaml
type 'a ground = Nil | Cons of 'a * 'a ground  (* 2b *)
```
Equation `(* 2b *)` is the usual definition of a list type, which we call a _ground_ list.


## Logic Types

In a relational program, a list engages with logic variables in manners like:
1) `[1;2;3]` --- No logic variable occurrence at all, the expression is absolutely concrete.
1) `[1;X;3]` --- There are only unknown list members.
1) `Cons (1,Y)` --- There is only an unknown sub-list.
1) `Cons (X,Y)` --- There are both unknown list members and an unknown sub-list.
1) `X` --- The list itself is wholly unknown. 

For all but the last case, we have some knowledge about the structure of the list. Thus we make the distinction
between a _guarded relational list_ and a (general) relational list:
```ebnf
relational list = logic variable | guarded relational list;
guarded relational list = 'Nil' | 'Cons', '(', list member, relational list, ')';
```
The type for a (polymorphic) relational list can therefore be implemented with mutual recursion 
between `(* 3a *)` and `(* 3b *)` as follows:

```ocaml
module Logic = struct
  type 'a logic = Value of 'a | Var of var_id 
end;;

module MyList = struct
  type ('a, 'b) t     = Nil | Cons of 'a * 'b     (* 1 *)
  type 'a ground      = ('a, 'a ground) t         (* 2 *)
  type 'b relational  =  'b guarded Logic.logic   (* 3a *)
  and  'b guarded     = ('b, 'b relational) t     (* 3b *) 
end;;
```

## Injected Types


Finally 
technique is so useful, let us see another example before moving on to demonstrate its utility. We define the Peano
 numbers. A _Peano number_ is a natural number denoted with two symbols `O` and `S` with auxiliary parentheses `()`.
 The symbol `O` is interpreted as the number zero, and the symbol `S` a successor function. Then the number one
 is denoted `S(O)`, two `S(S(O))`, three `S(S(S(O)))` and so on. Peano numbers are frequently used in relational programming.
```ocaml
module Peano = struct
  type 'a t = O | S of 'a
  type ground = ground t
end;;
```
Again the type `Peano.ground` is defined via an abstract type.




Level No. | Level Name
--        |--
1         | Abstract
2         | Ground
3         | Logic
4         | Injected



When we say that a type is at the _abstract level_, we do not mean that it is an _abstract type_.
In other words, we do not mean that it has no equation and no representation. Rather, we mean that
it is a framework such that types at the other levels are defined in terms of it.




The [program](hello2.ml) that we study in this lesson is almost the
same as [the one](../helloWorld/hello.ml) of the previous lesson, except that the line:
```ocaml
let str = !!("hello world!\n");;
```
now becomes:
```ocaml
let str : String.groundi = !!("hello world!\n");;
```
where we have added a type decoration `String.groundi`, and before that we have inserted a block
of type definitions, notably the String module:
```ocaml
@type 'a logic' = 'a logic with show;;

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
and the ground level coincide, but in general they are quite different, as we will see when working
with non-constant constructors of variant types.  

## The @type Syntax

In OCanren, type constructors are often defined by :
```
<type definition> ::= @type <typedef> with <plugins>

<plugins> ::= <plugin> { , <plugin> }

<plugin>  ::= show | gmap | <etc>
```
where the syntactic category `<typedef>` is the same as
[that](https://ocaml.org/releases/4.11/htmlman/typedecl.html) of OCaml. The most frequently used plugins
in OCanren are _show_ and _gmap_, providing for the defined type a string converson function
(like [Stdlib.string_of_int](https://ocaml.org/releases/4.11/htmlman/libref/Stdlib.html)) and
a structure preserving map function 
(a generalization of  [List.map](https://ocaml.org/releases/4.11/htmlman/libref/List.html))  respectively.


A type definition of the form `@type <typedef> with <plugins>` is expanded at the syntactic level
by GT into:
1) A type definition of the usual form `type <typedef>`, where the value of `<typedef>` is preserved, and
1) Several (auto-generated) plugin definitions.

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