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
Now open terminal under the 'helloworld' direcory, and:
```
> make
```
This would produce a `.opt` file, execution of which by:
```
> ./hello.opt
```
shall print `hello world!` on your terminal.

## Understand the Program

