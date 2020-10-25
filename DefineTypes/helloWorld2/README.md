# Say "Hello World!" Again

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

The purpose of this lesson is to expose the reader to the intricacies of types in OCanren. Whatever
types we want to work with in OCanren, let it be string, integer, list, tree, or tuple, etc., that type
must be defined for four times, corresponding to the four levels given in the table below:


Level No. | Level Name
--        |--
1         | Abstract
2         | Ground
3         | Logic
4         | Injected
