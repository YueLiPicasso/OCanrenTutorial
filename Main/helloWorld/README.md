# Say "Hello World!" in OCanren

The goal of this lesson is to execute and understand the
following piece of OCanren code.

```ocaml
open OCanren;;

let str = !!("hello world!\n");;

let _ =
  List.iter print_string @@
    Stream.take ~n:1 @@
      run q (fun q -> ocanren { q == str }) project;;
```

##  Execute the Program

We first execute the code. The source code resides in [hello.ml](hello.ml).
To compile and link it, you would need the [Makefile](Makefile).
Now open terminal under the `helloworld` direcory, and:
```
make
```
This would produce a `.opt` file, execution of which by:
```
./hello.opt
```
shall print `hello world!` on your terminal.

## Understand the Program

The first line:
```ocaml
open OCanren;;
```
makes the names from the module OCanren available for later use.
The source code of this module resides in
[OCanren.ml](../../Installation/ocanren/src/OCanren.ml). 
Inspecting the content thereof,  we shall see that basically
it includes two modules Logic and Core, and renames the module RStream
to Stream, and finally defines the Std module.

The interfaces of modules
Logic and Core reside in [Logic.mli](../../Installation/ocanren/src/core/Logic.mli)
and [Core.mli](../../Installation/ocanren/src/core/Core.mli) respectively. These will
be the most frequently referenced files when you program in OCanren. The
module Logic contains the secrets of OCanren's type system that enables
_typed_ relational programming, whereas the module Core provides all the
generic (miniKanren family) constructs such as `conde`, `fresh`, `run` and `==`
(unification) etc.

The second line:
```ocaml
let str = !!("hello world!\n");;
```
associates the value name `str` with the expression that
is the prefix symbol `!!` (double exclamation) applied to the
string literal `"hello world!\n"`.

The prefix symbol `!!` is also known as
_primitive injection_, which we will use very often with primitive
OCaml values such as strings, characters, constant constructors
(of variant values) etc.  It is provided by the module
Logic which is included in the module OCanren. We could see from the
interface of Logic that:
```ocaml
val (!!) : 'a -> ('a, 'a logic) injected
```
Therefore the expression str has type `(string, string logic) injected`
(read "string, string-logic, injected").
OCanren exclusively manipulates values of types of this form, which we
shall call an _injected type_. Conversion to an injected type is
 an integral part of OCanren programming.


The 3rd line:
```ocaml
let _ =
  List.iter print_string @@
    Stream.take ~n:1 @@
      run q (fun q -> ocanren { q == str }) project;;
``` 
finds all q's that unify with `str` then prints the first of them.

I now elaborate on aspects of this line.

### Type-wise

This line is for the side effect of the right hand side of the let-binding which
is divided into three sub-expressions by the right associative infix
operator `@@` that is provided by OCaml's core library
[Stdlib](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Stdlib.html).


The sub-expression:
```ocaml
List.iter print_string
```
consists of the OCaml [List](http://caml.inria.fr/pub/docs/manual-ocaml/libref/List.html)
standard library function:
```ocaml
val iter : ('a -> unit) -> 'a list -> unit
```
and the [Stdlib](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Stdlib.html) function:
```ocaml
val print_string : string -> unit
```
Therefore we can infer that the ensemble:
```ocaml
Stream.take ~n:1 @@ run q (fun q -> ocanren { q == str }) project
```
has the type `string list`. The module Stream is provided by the
[OCanren](../../Installation/ocanren/src/OCanren.ml#L22) module, and its interface is
[RStream.mli](../../Installation/ocanren/src/core/RStream.mli) where we could find:
```ocaml
val take : ?n:int -> 'a t -> 'a list
```
implying that the type of the ensemble:
```ocaml
run q (fun q -> ocanren { q == str }) project
```
is just `string RStream.t` (i.e., a stream of strings) that is in agreement with the return
type of `run` from the module [Core](../../Installation/ocanren/src/core/Core.mli#L120).
The 3rd line therefore
collects all possible answers to form a stream and takes one (the first one) from it to in turn
form a (singleton) list and print the member of this list.

### Programming-wise

The occurrence of `q` immediately after `run` is a name provided by
 [Core](../../Installation/ocanren/src/core/Core.mli#L225), and similar (predefined) names
as `qr`, `qrs`, `qrst` etc., used respectively when you query about two, three, and four
_logic variables_. In our hello-world example we only query about one logic variable, so we
use `q`. In other words, whenever you query about one logic variable, you shall always put
`q` immediately after `run`, and for two logic variables, put `qr`, and so on.

The `run` function
takes three arguments: a _size indicator_ (`q`, `qr`, etc.), a _query_ (`fun` ...) and the third
argument. The query shall list all logic variables that you query about immediately after
`fun` of the second argument, and the number of which shall agree with the size indicator.
In our example the logic variable
 queried about happens to be named `q`, but we can use any other name, like `honey`, then the
line would become:
```ocaml
run q (fun honey -> ocanren {honey == str}) project;;
```
Within `ocanren{}` goes your
goals, built using unification, conjunction, disjunction etc. The third argument
casts (projects) the
answer from an injected type to some user friendly type, in our case `string`.
 The type of _project_ is documented in [Logic.mli](../../Installation/ocanren/src/core/Logic.mli#L128).


### Camlp5 Syntax Extension-wise

The `ocanren{ <content> }` construct applies the [camlp5](https://camlp5.github.io/)
syntax preprocessor to the `<content>` according to user-defined rules that in our case is
 specified in [pa_ocanren.ml](../../Installation/ocanren/camlp5/pa_ocanren.ml).
 The effect is, for instance, we can use `==` rather than the longer `===` or `unify`
(both defined in [Core](../../Installation/ocanren/src/core/Core.mli#L36)) according to the [prescription](../../Installation/ocanren/camlp5/pa_ocanren.ml#L238).

## Summary

The most characteristic part of OCanren programming, compared with other dialects
of logic/relational programming such as Prolog and Scheme miniKanren, is that it has
a unique layer of type manipulation: The same piece of information like
"hello world!\n" simultaneously inhabits conceptually different domains signified
by the types _string_ and _(string, string logic) injected_.

A syntax preprocessor is used to make OCanren programs look intuitive in the eyes of an OCaml and
(Scheme based) miniKanren programmer. An OCanren program has to be compiled and linked, which
is helped by a standard Makefile (subject to minor modification).

