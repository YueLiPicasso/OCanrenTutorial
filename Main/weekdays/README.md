## Weekdays

In this lesson, we learn about working with variant types defined solely with
constant constructors. Such is the simplest form of variant types and learning it
could prepare us for working with more complicated variant types later on.

Our example program is [weekdays.ml](weekdays.ml), where we define a type
called _weekdays_ whose inhabitants are five distinct constant constructors:
_Monday_, ...,  _Friday_. The relational programming that we want to perform on this type
is relatively simple: we define the _next day_ relation. The emphasis, however, is on the
extra utilities: injection functions that we build in order to work with variant values in
OCanren.

The reader may now wish to `make` in the lesson directory and then `./test.opt`
for the result of some queries to the next-day relation.

After the initial `open OCanren;;` statement, the source code can be organized
into four logical parts: type definitions, injection utilities, relation
definitions and queries. This is also how a typical
OCanren program is organized. We explain the parts below. 

## Part 1: Type Definitions

This part connsists of:
```ocaml
@type 'a logic' = 'a logic with show;;
@type t = Monday | Tuesday | Wednesday | Thursday | Friday with show;;
@type ground = t with show;;
@type logic = t logic' with show;;
type groundi = (ground, logic) injected;;
```
Ultimately the injected level type constructor `groundi` is defined but it is based on two other
type constructors `ground` and `logic` which in turn are defined using the
abstract level type constructor `t`that happens to coincide with `ground`.

An `@type` definition, say:
```ocaml
@type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday with show;;
```
is expanded in the background into the familiar form:
```ocaml
type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday;;
```
together with a string conversion function:
```ocaml
val show_weekdays : weekdays -> string
```
We could observe the exact effect of using `@type`
by:
1) Marking as comment all lines except the `@type t = ...` line in the source file and save.
2) Amending the _BFLAGS_ variable in the [Makefile](Makefile#L11) with
the `-i`  option as in `BFLAGS = -rectypes -g -i` and save.
3) Running `make`  to instruct the terminal to display the signature of the source code. 

## Part 2: Injection Utilities

```ocaml
module Inj = struct
  let monday    = fun () -> !!(Monday)
  and tuesday   = fun () -> !!(Tuesday)
  and wednesday = fun () -> !!(Wednesday)
  and thursday  = fun () -> !!(Thursday)
  and friday    = fun () -> !!(Friday);;
end;;

open Inj;;
```
which is characteristic of OCanren programming. For every constructor of a (user-defined) variant
type we shall define an _injection function_ whose name must be the same as the constructor name
except that the initial letter is set in lowercase. The purpose of these injection functions
is two fold: firstly they perform type convertion in order for OCanren to process
(representations of) values of the user type;
secondly together with the `ocanren{}` environment they serve to make writing in OCanren
intuitive for an OCaml programmer. I shall explain these points now.

## Part 3: Relation Definitions

```ocaml
let next : groundi -> groundi -> goal = fun d1 d2 ->
  ocanren{
      d1 == Monday & d2 == Tuesday
    | d1 == Tuesday & d2 == Wednesday
    | d1 == Wednesday & d2 == Thursday
    | d1 == Thursday & d2 == Friday
    | d1 == Friday & d2 == Monday 
    };;
```

## Part 4: Queries

```ocaml
let _ =
  List.iter (fun x -> print_string (GT.show(ground) x ^ "\n")) @@ 
    Stream.take @@
      run q (fun r -> ocanren{next Monday r})  project;;


let _ =
  List.iter (fun x -> print_string (GT.show(ground) x ^ "\n")) @@ 
    Stream.take @@
      run q (fun r -> ocanren{next r Friday})  project;;
```

