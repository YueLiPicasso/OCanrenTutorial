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
does what is done by the familiar:
```ocaml
type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday;;
```
and additionally among others  creates a _show_ function for values of the type _weekdays_,
which converts any such value to a character string that facilitates display of the value.
This syntax extension is provided by the GT package.

We may pursue the difference between using `type` and using `@type` a bit further. Let's amend 
the [BFLAGS](Makefile#L11) variable with the `-i` (show info) option:
```
BFLAGS = -rectypes -g -i
```
and run `make`.

**Note**: Now the terminal may say that _make: Nothing to be done for 'all'._ This is becuase
 the _make_ utility recompiles only upon upddates of any prerequisite
 (See [GNU make](https://www.gnu.org/software/make/manual/)),
 but not upon updates of the Makefile itself. In response we could simply do some null
 modification of the source code, such as typing a space and then deleting it and saving the
 file, and run `make` again.

The terminal would lay bare all the semantical cannotations of this `@type` line, which we
reproduce below and in which we shall not get bogged down:
```ocaml
type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday
class virtual ['inh, 'extra, 'syn] weekdays_t :
  object
    method virtual c_Friday : 'inh -> 'extra -> 'syn
    method virtual c_Monday : 'inh -> 'extra -> 'syn
    method virtual c_Thursday : 'inh -> 'extra -> 'syn
    method virtual c_Tuesday : 'inh -> 'extra -> 'syn
    method virtual c_Wednesday : 'inh -> 'extra -> 'syn
  end
val gcata_weekdays : ('a, weekdays, 'b) #weekdays_t -> 'a -> weekdays -> 'b
class ['a] show_weekdays_t :
  'b ->
  object
    constraint 'a = weekdays
    method c_Friday : unit -> 'a -> string
    method c_Monday : unit -> 'a -> string
    method c_Thursday : unit -> 'a -> string
    method c_Tuesday : unit -> 'a -> string
    method c_Wednesday : unit -> 'a -> string
  end
val weekdays :
  (('a, weekdays, 'b) #weekdays_t -> 'a -> weekdays -> 'b,
   < show : weekdays -> string >,
   (('c -> weekdays -> 'd) -> ('c, weekdays, 'd) #weekdays_t) ->
   'c -> weekdays -> 'd)
  GT.t
val show_weekdays : weekdays -> string
```