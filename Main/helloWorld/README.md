# Say "Hello World!" in OCanren


##  Executing the Program

The source code has to be compiled and linked, for which you would need the [Makefile](Makefile).
Now open terminal under your local copy of the [`helloWorld`](./) direcory, and:
```
make
```
This would produce a native-code file `hello.opt`, execution of which by:
```
./hello.opt
```
shall print `hello world!` in your terminal.

## Understanding the Program

The first line:
```ocaml
open OCanren;;
```
makes the names from the module OCanren available for later use.

### Important Interfaces   

The source code of the module OCanren resides in
[OCanren.ml](../../Installation/ocanren/src/OCanren.ml)
(It does not have an accompanying `.mli` file). 
Inspecting the content thereof,  we shall see that basically
it includes two modules [Logic](../../Installation/ocanren/src/core/Logic.mli)
and [Core](../../Installation/ocanren/src/core/Core.mli), and renames the module
[RStream](../../Installation/ocanren/src/core/RStream.mli)
to Stream, and finally defines the Std module. You should
open the module OCanren at the beginning of every source file where
you use OCanren features.   

The second line:
```ocaml
let str = !!("hello world!\n");;
```
associates the value name `str` with the expression that
is the prefix operator `!!` (named _primitive injection_)
applied to the string literal `"hello world!\n"`.

### Injecting to the OCanren Internal Representation

The operator `!!`, provided by the module Logic, makes type conversion to the OCanren
internal representation, something like what a calculator program
does when it receives an input string "1" and converts it to the integer
or floating-point type for further processing. We could see from the interface that:
```ocaml
val (!!) : 'a -> ('a, 'a logic) injected
```
The `injected` type constructor is provided by the module Logic as an abstract type
 (so we do not concern ourselves with its implementation).

### Logic Variables

The `logic` type constructor which appears in the type of `!!` above is also
provided by the module Logic. 
It takes one type parameter and its type representation is exposed: we could
see from the module interface that it has two constructors
`Var` and `Value`,  representing respectively a _logic variable_ and a _concrete value_
over/of the parameter type, in the sense that wrt. the arithmetic expression `1 + x` we
say that `x` is a logic variable over the integer type and `1` is a concrete value of
the integer type. 

The 3rd line:
```ocaml
let _ =
  List.iter print_string @@
    Stream.take ~n:1 @@
      run q (fun q -> ocanren { q == str }) project;;
``` 
is divided into three sub-expressions by the right associative infix
operator `@@` that is provided by OCaml's core library
[Stdlib](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Stdlib.html). The most
 important sub-expression is:
 ```ocaml
 run q (fun q -> ocanren { q == str }) project
 ```
called a _run-expression_ whose most important part is: `q == str`. 

### Unification

Given two expressions _expr_<sub>1</sub> and _expr_<sub>2</sub> of the same type, we say that
they _unify_, denoted _expr_<sub>1</sub> `==` _expr_<sub>2</sub> , 
if both have zero or more sub-expressions
considered as logic variables,  and by replacing these logic variables by some expressions
(the replacement shall respect types) we can make the resulting expressions
syntactically identical.

**Example** Both `(x + 1) == (2 + y)` and `Node (x,1) == Node (2,y)` are
true since  replacing `x` by `2`,  and `y` by `1` makes both sides of `==` the expression `2 + 1` or `Node (2,1)` respectively.

**Example** `z == "I'm a string"` is true since replacing the logic variable `z` with
the constant `"I'm a string"` makes both sides of `==` the same constant.

### Parsing the _Run-Expression_

We can parse the run-expression following the syntax below,
 which is given in [EBNF](https://github.com/YueLiPicasso/language-grammars))
except that occurrences of the meta-identifier `etc` signifies omission:
there is no syntactic category named `etc`.

```ebnf
run expression = 'run',  size indicator, goal, answer handler ;

size indicator =  'one' | 'two' | 'three' | 'four' | 'five'
                | 'q'   | 'qr'  | 'qrs'   | 'qrst' | 'qrstu'
		| '(', size indicator, ')'
		| 'succ', size indicator ;

goal = 'fun', parameters, '->', 'ocanren', '{', goal body, '}' ;

answer handler = 'project' | etc ;

parameters = etc ;

goal body = etc ;
```

> To do: Check the camlp5 extension for the goal-body category

.
The `q == str`  proposition is essentially 

All logic variales in OCanren are introduced either
as parameters of `fun` (as in our program) or as parameters of the `fresh` keyword
(we'll see in later lessons).  

In `q == str`, `q` itself is a logic variable but `str` does not contain any, so
there is only one (rather trivial) answer: replace `q` by `str`.




### Type-wise

This line


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

