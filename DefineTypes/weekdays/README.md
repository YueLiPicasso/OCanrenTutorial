## Weekdays

In this lesson, we learn about working with variant types defined solely with
constant constructors. Our example program is [weekdays.ml](weekdays.ml), where
we define a type called _weekdays_ whose inhabitants are five distinct constant constructrs:
_Monday_, _Tuesday_ etc. The relational programming that we want to perform on this type
is relatively simple: we define the _next day_ relation. The emphasis, however, is on the
extra infrastructure that we must build in order to work with such basic variant values in
OCanren. We inspect the source code block by block.

The 1st block:
```ocaml
open OCanren;;
```
provides the basic OCanren infrastructure.

The 2ed block:
```ocaml
@type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday with show;;
```
does what is done by the familiar:
```ocaml
type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday;;
```
and additionally creates a _show_ function for values of the type _weekdays_, which converts
any such value to a character string that facilitates display of the value. 