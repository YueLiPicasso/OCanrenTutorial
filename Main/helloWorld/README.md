# Say "Hello World!" in OCanren


##  Executing the Program

The source code has to be compiled and linked, for which you would need the [Makefile](Makefile).
Now open terminal under the `helloworld` direcory, and:
```
make
```
This would produce a native-code file `hello.opt`, execution of which by:
```
./hello.opt
```
shall print `hello world!` on your terminal.

## Understanding the Program

The first line:
```ocaml
open OCanren;;
```
makes the names from the module OCanren available for later use.


The source code of the module OCanren resides in
[OCanren.ml](../../Installation/ocanren/src/OCanren.ml)
(It does not have an interface `.mli` file). 
Inspecting the content thereof,  we shall see that basically
it includes two modules [Logic](../../Installation/ocanren/src/core/Logic.mli)
and [Core](../../Installation/ocanren/src/core/Core.mli), and renames the module
[RStream](../../Installation/ocanren/src/core/RStream.mli)
to Stream, and finally defines the Std module. 

The second line:
```ocaml
let str = !!("hello world!\n");;
```
associates the value name `str` with the expression that
is the prefix operator `!!` (named _primitive injection_)
applied to the string literal `"hello world!\n"`.

The operator `!!`, provided by the module Logic, make type conversion to the OCanren
internal representation, something like what a calculator program
does when it receives an input string "1" and converts it to the integer
or floating-point type for further processing. We could see from the interface that:
```ocaml
val (!!) : 'a -> ('a, 'a logic) injected
```
OCanren internally manipulates values of types of the form `('a, 'a logic) injected`.

The `injected` type constructor is provided by the module Logic as an abstract type.

The `logic` type constructor is also
provided by the module Logic, but as a new variant type.
It has two constructors `Var` and `Value` which
represent respectively a logic _Var_<nospace>iable and a concrete _Value_
of the parameter type of `logic`.


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

This line is divided into three sub-expressions by the right associative infix
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
has the type `string list`. The module Stream is provided by the module
OCanren which is opened at the beginning, and its interface is
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
`fun` , and the number of which shall agree with the size indicator.
In our example the logic variable
 queried about happens to be named `q`, but we can use any other name, like `honey`, then the
line would become:
```ocaml
run q (fun honey -> ocanren {honey == str}) project;;
```
Within `ocanren{}` goes your
goals, built using unification, conjunction, disjunction etc. The third argument
converts the
answer from an injected type to some user friendly type.
 The type of `project` is documented in [Logic.mli](../../Installation/ocanren/src/core/Logic.mli#L128).


### Camlp5 Syntax Extension-wise

The `ocanren{ <content> }` construct applies the [camlp5](https://camlp5.github.io/)
syntax preprocessor to the `<content>` according to user-defined rules that in our case is
 specified in [pa_ocanren.ml](../../Installation/ocanren/camlp5/pa_ocanren.ml).
 The effect is, for instance, we can use `==` rather than the longer `===` or `unify`
(both defined in [Core](../../Installation/ocanren/src/core/Core.mli)) according to the [prescription](../../Installation/ocanren/camlp5/pa_ocanren.ml#L238).

## Summary

When working with OCanren, data like _hello world!_  inhabits the user interface type
`string` as well as the  OCanren-internal type `(string, string logic) injected`.

A syntax preprocessor is used to make OCanren programs look intuitive in the eyes of an OCaml and
(Scheme based) miniKanren programmer. An OCanren program has to be compiled and linked, which
is helped by a standard Makefile (subject to minor modification).

