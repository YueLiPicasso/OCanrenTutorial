## Weekdays

In this lesson, we learn about working with variant types defined solely with
constant constructors. Our example program is [weekdays.ml](weekdays.ml), where
we define a type called _weekdays_ whose inhabitants are five distinct constant constructrs:
_Monday_, _Tuesday_ etc. The relational programming that we want to perform on this type
is relatively simple: we define the _next day_ relation. The emphasis, however, is on the
extra infrastructure that we must build in order to work with such basic variant values in
OCanren.

