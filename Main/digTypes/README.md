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
The type constructor `MyList.t` is called an _abstract list type_ for it not only abstracts over the list member type
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
 

<hr>

**Example.** Below are some inhabitants of the type `int logic_list`:
```ocaml
Value Nil;;                    (** case 1: a guarded logic list *)
Value (Cons (1, Value Nil));;  (** case 1: a guarded logic list which is an integer
                                           cons'ed to another guarded logic list *)
Value (Cons (1, Var (1,[])));; (** case 3: a  guarded logic list which is an integer
                                           cons'ed to a pure logic list*)
Var (1,[]);;                   (** case 5: a pure logic list *)				  	  
```
We could see that the inhabitants are logic lists where logic variables may only denote unknown sub-lists.
This is because the parameter of `logic_iist` is instantiated by a ground type (`int`).
To allow logic variables as list members (as in cases 2 and 4), we need to define the type of _logic number_ and use it
as the type parameter instead of `int`, as follows.    
<hr>

 We define the Peano
 numbers. A _Peano number_ is a natural number denoted with two symbols `O` and `S` with auxiliary parentheses `()`.
 The symbol `O` is interpreted as the number zero, and the symbol `S` a successor function. Then the number one
 is denoted `S(O)`, two `S(S(O))`, three `S(S(S(O)))` and so on. Peano numbers are frequently used in relational programming,
 where they appear like:
 - `O`, `S(O)` --- Ground (Peano) numbers.
 - `X`, `S(X)`, `S(S(X))` --- Numbers with a logic variable (`X`).

Regarding all these as _logic numbers_, we distinguish:
   - `X` --- The pure logic number.
   - `O`, `S(O)`, `S(X)`, `S(S(X))` --- Guarded logic numbers.

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
Similar to logic lists, a logic number is either i) a pure logic number (e.g., `X`) or ii) a guarded logic number
that is either `O` or `S` applied recursively to a logic number. Pure and guarded logic numbers are again
distinguished using constructors `Var` and `Value` respectively. 

<hr>

**Example.** Below are some inhabitants of the type `Peano.logic`:
```ocaml
Var (1,[]);;                        (** a pure logic number X *)
Value O;;                           (** a guarded logic number which is the constructor [O] *)
Value (S (Var (1,[])));;            (** a guarded logic number S(X) which is the constructor [S] applied to
                                        a (pure) logic number X *)
Value (S (Value O))                 (** a guarded logic number S(O) which is the constructor [S] applied to
                                        a (guarded) logic number which is the constructor [O] *)
Value (S (Value (S (Var (1,[])))))  (** a guarded logic number S(S(X)) *)
```
Then the type `Peano.logic logic_list`
has the following inhabitants:
```ocaml
Value Nil;;                                       (* case 1 *)
Value (Cons (Value (S (Value O)) , Value Nil));;  (* case 1 *)
Value (Cons (Var (1,[]), Value Nil));;            (* case 2 *)
Value (Cons (Value (S (Value O)) , Var (2,[])));; (* case 3 *)
Value (Cons (Var (1,[]), Var (2,[])));;           (* case 4 *)
Var (1,[]);;                                      (* case 5 *)
```
Therefore, when we talk about a list of numbers in relational programming, we are actually talking about a
logic list of logic numbers. 
<hr>

### More abstraction over logic types

Compare the types of logic lists and logic numbers (reproduced below):
```ocaml
(* Comparing the types of logic lists and logic numbers *)

(* The logic list type*)
type 'b logic_list  =  Value of 'b guarded_logic_list
                    |  Var   of int * 'b logic_list list
and  'b guarded_logic_list  = ('b, 'b logic_list) MyList.t    

(* logic number type. Excerpt from module Peano *)
type logic   = Value of guarded       
             | Var of int * logic list
and  guarded = logic t   
```
We could see that they both involve the constructors
`Value` and `Var` with  similar argument structures: the `Value` constructor's argument is always a guarded type,
and the `Var` constructor's first argument is always `int` and second argument is always a `list` of the logic type
itself. This imlpies that we can extract these common parts for reuse
, by equating them to a new type constructor with one
type parameter that abstracts from the guarded types, as follows:
```ocaml
(** The new, reusable type constructor for defining logic types *)
module MyLogic = struct
  type 'a logic = Value of 'a | Var of int * 'a logic list
end;;
```
Next time when we what to define `('a1, ..., 'an) Something.logic`, instead of writing:
```ocaml
(** longer logic type definition  *)
module Something = struct
  type ('a1, ..., 'an, 'self) t = (* ... type information omitted *)
  type ('a1, ..., 'an) logic = Value of ('a1, ..., 'an) guarded
                             | Var of int * ('a1, ..., 'an) logic list    
  and ('a1, ..., 'an) guarded = ('a1, ..., 'an, ('a1, ..., 'an) logic) t
end;;
```
we could write:
```ocaml
(** shorter logic type definition  *)
module Something = struct
  type ('a1, ..., 'an, 'self) t = (* ... type information omitted *)
  type ('a1, ..., 'an) logic =  ('a1, ..., 'an) guarded MyLogic.logic 
  and ('a1, ..., 'an) guarded = ('a1, ..., 'an, ('a1, ..., 'an) logic) t
end;;
```
for we can derive the longer from the shorter using `MyLogic` (the reader may
write down the derivation as an exercise).
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


## Injected Types

The `injected` type constructor collects the corresponding ground and logic type constructors,
to which we assign the name `groundi` (read "groun-dee"):
```ocaml
(** Complete definitions of injected types
    for lists and Peano numbers *)

module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b
  type 'a ground = ('a, 'a ground) t
  type 'b logic   =  ('b, 'b logic) t MyLogic.logic
  type ('a, 'b) groundi = ('a ground, 'b logic) injected
end;;

module Peano = struct
  type 'a t   = O | S of 'a
  type ground = ground t
  type logic  =  logic t MyLogic.logic
  type groundi = (ground, logic) injected
end;;
```
The `injected` type constructor is abstract in the sense that its type information is hidden from the user. Therefore
we do not concern ourselves as to what an inhabitant of an injected type looks like.  

## Summary

OCanren works on injected types that are defined via abstract, ground and logic types. The table below
organizes these types into four levels by complexity and dependency.

Level No. | Level Name
--        |--
1         | Abstract
2         | Ground
3         | Logic
4         | Injected

As examples, we defined types of Peano numbers and polymorphic lists , each showing the four-level structure.
We give the general form of definig the injected representation of a regular recursive type:
```ocaml
(** Template of an injeced, regular recursive type *)

module MyLogic = struct
  type 'a logic = Value of 'a | Var of int * 'a logic list
end;;

module Something = struct
  type ('a1, ..., 'an, 'self) t = (* ... add type information here *)
  type ('a1, ..., 'an) ground = ('a1, ..., 'an, ('a1, ..., 'an) ground) t
  type ('b1, ..., 'bn) logic =  ('b1, ..., 'bn, ('b1, ..., 'bn) logic) t MyLogic.logic
  type ('a1, ..., 'an, 'b1, ..., 'bn) groundi = (('a1, ..., 'an) ground, ('b1, ..., 'bn) logic) injected
end;;
```
The reader may apply this template to define his own (regular recursive) types. The template for defining non-recursive types
 is even simpler: no need to abstract over self, i.e.,  no need for the `'self` parameter. The consequence is that the abstract
 type and the ground type coincide:
 ```ocaml
(** Template of an injeced, non-recursive type *)

module MyLogic = struct
  type 'a logic = Value of 'a | Var of int * 'a logic list
end;;

module Something = struct
  type ('a1, ..., 'an) t = (* ... add type information here *)
  type ('a1, ..., 'an) ground = ('a1, ..., 'an) t
  type ('b1, ..., 'bn) logic =  ('b1, ..., 'bn) t MyLogic.logic
  type ('a1, ..., 'an, 'b1, ..., 'bn) groundi = (('a1, ..., 'an) ground, ('b1, ..., 'bn) logic) injected
end;;
```
 The template for non-regular recursive types is not discussed here.

### Compiling the type definitions

The types that we learnt in this lesson are put together
in the file [digTypes.ml](digTypes.ml) which can be compilied
successfully using the lightweight [Makefile](Makefile).

Note that we defined
the module `MyLogic`  for pedagogical purposes only, so that we do not
have to refer to the OCanren source code. The reader is encouraged to find
the corresponding definitions in the source code by himself. Moreover,
the `Peano` and `MyList` modules correspond to the OCanren standard libraries
`LNat` and `LList` respectively where the leading `L` in the module names
stands for "logic".

Note also that 
we need the `-rectypes` compiler option in the makefile to deal with
the rather liberal recurisve types that appear in this lesson.