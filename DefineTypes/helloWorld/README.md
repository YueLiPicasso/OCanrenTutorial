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
[OCanren.ml](../../ocanren/src/OCanren.ml). 
Inspecting the content thereof,  we shall see that basically
it includes two modules Logic and Core, and renames the module RStream
to Stream, and finally defines the Std module.

The interfaces of modules
Logic and Core reside in [Logic.mli](../../ocanren/src/core/Logic.mli)
and [Core.mli](../../ocanren/src/core/Core.mli) respectively. These will
be the most frequently referenced files when you program in OCanren. The
module Logic contains the secrets of OCanren's type system that enables
typed relational programming, whereas the module Core provides all the
miniKanren-like constructs such as `conde`, `fresh`, `run` etc.

The second line:
```ocaml
let str = !!("hello world!\n");;
```
associates the value name str with the expression that
is the prefix symbol !! (double exclamation) applied to the
string literal "hello world!\n".

The prefix symbol !! is also known as
_primitive injection_, which we will use very often with primitive
OCaml values such as strings, characters, constant constructors
(of variant values) etc.  It is provided by the module
Logic which is included in the module OCanren. We could see from the
interface of Logic that:
```ocaml
val (!!) : 'a -> ('a, 'a logic) injected
```
Therefore the expression str has type (string, string logic) injected.
OCanren exclusively manipulates values of types of this form.

