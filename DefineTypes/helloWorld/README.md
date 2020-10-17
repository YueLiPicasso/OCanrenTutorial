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

The first line
```ocaml
open OCanren;;
```
makes the names from [OCanren.ml](../../ocanren/src/OCanren.ml) available
for later use. Inspecting the content of `OCanren.ml` we see that basically
it includes two modules `Logic` and `Core`, and renames the module `RStream`
to `Stream`, and finally defines the `Std` module. The interfaces of modules
`Logic` and `Core` reside in [Logic.mli](../../ocanren/src/core/Logic.mli)
and [Core.mli](../../ocanren/src/core/Core.mli) respectively.