# Say "Hello World!" Again

The purpose of this lesson is to expose the reader to the intricacies of types in OCanren. Whatever
types we want to work with in OCanren, let it be string, integer, list, tree, or tuple, etc., that type
is always defined in four steps, corresponding to the four levels given in the table below:


Level No. | Level Name
--        |--
1         | Abstract
2         | Ground
3         | Logic
4         | Injected


The [program](hello2.mi) that we study in this lesson is almost the
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

When we say that a type is at the _abstract level_, we do not mean that it is an _abstract type_.
In other words, we do not mean that it has no equation and no representation. Rather, we mean that
it is a framework such that types at the other levels are defined in terms of it. In the String
module, the type `t` is at the abstract level, and the type `ground` is at the ground level,
`logic` at the logic level, and `groundi` at the injected level. In our example the abstract level
and the ground level coincide, but in general they are quite different, as we will see when working
with non-constant constructors of variant types.  

Now we are ready to dig into the details.

## The @type Syntax

In OCanren, types are often defined by :
```
<type definition> ::= @type <typedef> with <plugins>

<plugins> ::= <plugin> { , <plugin> }

<plugin>  ::= show | gmap | <etc>
```
where the syntactic category `<typedef>` is the same as
[that](https://ocaml.org/releases/4.11/htmlman/typedecl.html) of OCaml.
A line of `@type <typedef> with <plugins>` is expanded at the syntactic level
by GT into a line of the usual `type <typedef>` togeter with several (auto-generated) plugin definitions.  
The most frequently used plugins
in OCanren is _show_ and _gmap_, providing for the defined type a (to-)string converson function
(like [Stdlib.string_of_int](https://ocaml.org/releases/4.11/htmlman/libref/Stdlib.html)) and
a structure preserving mapping function 
(a generalization of  [List.map](https://ocaml.org/releases/4.11/htmlman/libref/List.html))  respectively.



## The Plugins

(t1, ..., tn) t

show(t1) <= show(t2) ... show(tn)

Similar for gmap.






GT.string is the same type as the OCaml built-in string type and it additional supports
GT features.