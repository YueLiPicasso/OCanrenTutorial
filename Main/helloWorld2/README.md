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
(** The abstract list type *)
module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b 
end;;
```
The type constructor `MyList.t` is called an _abstract list type_ for it not only abstracts over the list memeber type
 by means of the type parameter `'a`,  but also (and more importantly) abstracts over the list tail type or
 in other words over the list type itself  by means of the type parameter `'b`. We can use the abstract list type
 to define other useful types of lists, as we shall see next.   

## Ground Types

The usual definition of the recursive list type can be decomposed into the three finer steps:
1. Abstracting over the self type.
1. Instantiating the abstract type by self type.
1. Equating the instance with the self type to close the loop.

As in:
```ocaml
(** Defining the ground list type from the abstract type *)
module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b   (* 1 *)
  type 'a ground = ('a, 'a ground) t        (* 2 *)
end;;
```
Equation `(* 1 *)` is for step 1.  Equation `(* 2 *)` is for steps 2 and 3: if you instantiate `'b` with
`'a ground` in `(* 1 *)`, you would get (literally):
```
type ('a, 'a ground) t = Nil | Cons of 'a * 'a ground  (* 1b *)
```
Then by `(* 1b *)` and `(* 2 *)` we have:
```ocaml
type 'a ground = Nil | Cons of 'a * 'a ground  (* 2b *)
```
Equation `(* 2b *)` is the usual definition of a list type, which we call a _ground list type_. The abstract list type
can also be used to define logic list types. 


## Logic Types

In a relational program, a list engages with logic variables in cases like:
1) `Cons (1,Nil)` and  `Nil` --- No logic variable occurrence at all. The lists are  actually ground.
1) `Cons (X, Nil)`           --- There are only unknown list members.
1) `Cons (1,Y)`              --- There is only an unknown sub-list.
1) `Cons (X,Y)`              --- There are both unknown list members and an unknown sub-list.
1) `X`                       --- The list itself is wholly unknown. 

Due to possible presence of logic variables in various ways shown above, the concept of a list in a relational
program is more general than the concept of a ground list. We call them _logic lists_, for which we now define
a type.

Observe that for cases 1-4, we have some knowledge about the structure of the list: we know whether
it is empty or not because there is a top level constructor to inspect. We call such logic lists _guarded_.
But for case 5,  we have no idea about the structure of the list for there is no top level constructor
to provide a clue : we call it a _pure logic list_, which is just a logic variable. This is an important distinction
needed for typing logic lists, and we summarize it as follows:

```ebnf
logic list          = pure logic list
                    | guarded logic list;
		    
pure logic list     = logic variable;

guarded logic list  = 'Nil'
                    | 'Cons', '(', logic list member, logic list, ')';
```
The type for a (polymorphic) logic list can then be implemented with mutual recursion 
 as follows:
```ocaml
(** A logic list type definition *)
type 'b logic_list  =  Value of 'b guarded_logic_list
                    |  Var   of int * 'b logic_list list
and  'b guarded_logic_list  = ('b, 'b logic_list) MyList.t    
```
where the constructors `Value` and `Var` are used to distinguish a guarded logic list from a pure
 logic list. Moreover,  The `Var` constructor's `int` argument uniquely identifies a pure logic list, and the
 second argument is a (possibly empty) list of logic lists that can be used to instantiate the pure
 logic list. 

### More abstraction over logic types

 Let us see another example of logic types. We define the Peano
 numbers. A _Peano number_ is a natural number denoted with two symbols `O` and `S` with auxiliary parentheses `()`.
 The symbol `O` is interpreted as the number zero, and the symbol `S` a successor function. Then the number one
 is denoted `S(O)`, two `S(S(O))`, three `S(S(S(O)))` and so on. Peano numbers are frequently used in relational programming,
 in cases like:
 1. `O`, `S(O)` --- Ground (Peano) numbers.
 1. `X`, `S(X)`, `S(S(X))` --- Numbers with a logic variable (`X`).

Regarding all these as _logic numbers_, we distinguish:
   1. `X` --- The pure logic number.
   1. `O`, `S(O)`, `S(X)`, `S(S(X))` --- Guarded logic numbers.

We can define abstarct, ground and logic Peano number types as well:
```ocaml
(** Abstarct, ground and logic Peano number types *)
module Peano = struct
  type 'a t    = O | S of 'a             (** Abstract *)
  type ground  = ground t                (** Ground *) 
  type logic   = Value of guarded        (** Logic  *)
               | Var of int * logic list
  and  guarded = logic t                 (** ... and Guarded *)
end;;
```
Comparing the types of logic lists and logic numbers, we could see that they both involve the constructors
`Value` and `Var` with  similar argument structures: the `Value` constructor's argument is always a guarded type,
and the `Var` constructor's first argument is always `int` and second argument is always a `list` of the logic type
itself. This imlpies that we can extract these common parts for reuse
when defining other logic types, by equating them to a new type constructor with one
type parameter that abstracts from the guarded types, as follows:
```ocaml
(** A reusable type constructor for defining logic types *)
module MyLogic = struct
  type 'a logic = Value of 'a | Var of int * 'a logic list
end;;
```
Next time when we what to define `('a1, ..., 'an) Something.logic`, instead of writing:
```ocaml
(** longer logic type definition  *)
module Something = strcut
  type ('a1, ..., 'an, 'self) t  (* ... type information omitted *)
  type ('a1, ..., 'an) logic = Value of ('a1, ..., 'an) guarded
                             | Var of int * ('a1, ..., 'an) logic list    
  and ('a1, ..., 'an) guarded = ('a1, ..., 'an, ('a1, ..., 'an) logic) t
end;;
```
we could write:
```ocaml
(** shorter logic type definition  *)
module Something = strcut
  type ('a1, ..., 'an, 'self) t  (* ... type information omitted *)
  type ('a1, ..., 'an) logic =  ('a1, ..., 'an) guarded MyLogic.logic 
  and ('a1, ..., 'an) guarded = ('a1, ..., 'an, ('a1, ..., 'an) logic) t
end;;
```
for we can derive `(** longer *)` from `(** shorter *)` and `MyLogic`.
As examples: the logic list type can be rewritten as:
```ocaml
(** Defining the logic list type using [MyLogic.logic] *)
module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b            
  type 'b logic   =  'b guarded MyLogic.logic and 'b guarded  = ('b, 'b logic) t           
end;;
```
and the logic number type as:
```ocaml
(** Defining the logic number type using [MyLogic.logic] *)
module Peano = struct
  type 'a t   = O | S of 'a
  type logic  =  guarded MyLogic.logic and guarded = logic t
end;;
```
Or even shorter, skipping the guarded types:
```ocaml
(** Concise definitions of abstract and logic types
   for lists and Peano numbers *)

module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b            
  type 'b logic   =  ('b, 'b logic) t MyLogic.logic           
end;;

module Peano = struct
  type 'a t   = O | S of 'a
  type logic  =  logic t MyLogic.logic
end;;
```
More generally (with ground type added):
```ocaml
(** General definitions of abstract, ground and logic types *)
module Something = strcut
  type ('a1, ..., 'an, 'self) t  (* ... type information omitted *)
  type ('a1, ..., 'an) ground = ('a1, ..., 'an, ('a1, ..., 'an) ground) t
  type ('a1, ..., 'an) logic =  ('a1, ..., 'an, ('a1, ..., 'an) logic) t MyLogic.logic 
end;;
```

## Injected Types

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