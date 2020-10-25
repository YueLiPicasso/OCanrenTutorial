## Weekdays

In this lesson, we learn about working with variant types defined solely with
constant constructors. Our example program is [weekdays.ml](weekdays.ml), where
we define a type called _weekdays_ whose inhabitants are five distinct constant constructors:
_Monday_, _Tuesday_ etc. The relational programming that we want to perform on this type
is relatively simple: we define the _next day_ relation. The emphasis, however, is on the
extra infrastructure that we must build in order to work with such basic variant values in
OCanren. The reader may now wish to `make` in the lesson directory and then `./test.opt`
for the result of some queries to the next-day relation.  And now we inspect the source code
block by block.

The 1st block:
```ocaml
open OCanren;;
```
provides the basic OCanren infrastructure.

The 2ed block:
```ocaml
@type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday with show;;
```
is syntactic sugar which is expanded into 
```ocaml
type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday;;
```
and among others a _show_ function:
```ocaml
val show_weekdays : weekdays -> string
```
which converts any value of the type _weekdays_ to a character string
that facilitates display of the value. This `@type` syntax is provided by the GT package.

**Note**: We may observe the difference between using `type` and using `@type`
by amending the [BFLAGS](Makefile#L11) variable with the `-i` (display module interface only)
option: `BFLAGS = -rectypes -g -i` (in order to instruct the terminal to display the signature of the _weekdays_ source code. The
reader can mark as comment all lines below the `@type` line in the source file  and then `make`
to see what exactly the `@type` line expands into.


The 3rd block is: 
```ocaml
module Inj = struct
  let monday    = fun () -> !!(Monday)
  and tuesday   = fun () -> !!(Tuesday)
  and wednesday = fun () -> !!(Wednesday)
  and thursday  = fun () -> !!(Thursday)
  and friday    = fun () -> !!(Friday);;
end;;

```
which is characteristic of OCanren programming. For every constructor of a (user-defined) variant
type we shall define an _injection function_ whose name must be the same as the constructor name
except that the initial letter is set in lowercase. The purpose of these injection functions
is two fold: firstly they perform type convertion in order for OCanren to process
(representations of) values of the user type;
secondly together with the `ocanren{}` environment they serve to make writing in OCanren
intuitive for an OCaml programmer. I shall explain these points now.

**Type Hierarchy** OCanren involves a four-level type hierarchy:


Level No. | Level Name
--        |--
1         | Abstract
2         | Ground
3         | Logic
4         | Injected






, notably the _show_weekdays_
 function, which is invoked as `GT.show(weekdays)` in our program.  
