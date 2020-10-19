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
_typed_ relational programming, whereas the module Core provides all the
generic (miniKanren family) constructs such as `conde`, `fresh`, `run` and `==`
(unification) etc.

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
Therefore the expression str has type (string, string logic) injected (read "string, string-logic, injected").
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
finds all q's that unify with str then prints the first of them.

I now elaborate on aspects of this line.

### Type-wise

This line is for the side effect of the right hand side of the let-binding which
is divided into three sub-expressions by the right associative infix
operator `@@` that is provided by OCaml's core library
[Stdlib](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Stdlib.html).
The wild card is finally assigned the constant value `()` of type unit.


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
has the type _string list_. The module name _Stream_ is provided by [the
OCanren module](../../ocanren/src/OCanren.ml), and its interface is
[RStream.mli](../../ocanren/src/core/RStream.mli) where we could find:
```ocaml
val take : ?n:int -> 'a t -> 'a list
```
implying that the type of the ensemble:
```ocaml
run q (fun q -> ocanren { q == str }) project
```
is just _string RStream.t_ (i.e., a stream of strings) that is in agreement with the return
type of _run_ from the module [Core](../../ocanren/src/core/Core.mli).

### programming-wise

The occurrence of _q_ immediately after _run_ is a name provided by
the module [Core](../../ocanren/src/core/Core.mli), and similar (predefined) names
as _qr_, _qrs_, _qrst_ etc., used respectively when you query about two, three, and four
_logic variables_. In our hello-world example we only query about one logic variable, so we
use _q_. In other words, whenever you query about one logic variable, you shall always put
_q_ immediately after _run_, and for two logic variables, put _qr_, and so on. The _run_ function
takes three arguments: a _size indicator_ (q, qr, etc.), a _query_ (fun ...) and the third
argument. The query shall list all logic variables that you query about immediately after
_fun_, and whose number shall agree with the size indicator. Within `ocanren{}` goes your
goals, built using unification, conjunction, disjunction etc. The third argument is some
boilerplate piece that does type project (the reverse process of type injection)
or reification (to provide pretty, easy-to-read names for free logic variables). 


### Camlp5 Syntax Extension-wise

The kind of type reasoning we went through above happens in everyday OCanren programming.
Now we explain at a high level about the expression:
```ocaml
run q (fun q -> ocanren { q == str }) project
```
The q in `fun q ->` is a logic variable (the kind of variable that OCanren works
with) whose value we want OCanren to compute. The `q == str` part reads "q unifies with str".
The `ocanren{}` construct is a syntax transformer: among others, it converts `==` into `===` that
is defined in [Core]((../../ocanren/src/core/Core.mli)). Using `ocanren{}`we can write relational
programs in a less verbose syntax, for instance, we can use `==` rather than the longer `===` for
unification. `ocanren{}` is also known as a user-defined [camlp5](https://camlp5.github.io/)
syntax extension, and it is specified in [pa_ocanren.ml](../../ocanren/campl5/pa_ocanren.ml).

