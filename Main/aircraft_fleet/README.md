# The Range of a Fleet of Aircraft 


## Background

There is a fleet of N identical aircraft, where every aircraft has a fuel capacity of C liters and
fuel efficiency of R miles per liter of fuel. The fleet has a mission of reaching some target located
at a distance D from the airbase, where CR < D < NCR. Once taking off, there
is no more airbase along the way for the fleet to land and refuel. The fleet adopts such a  strategy that
at any stage, any one aircraft could be abandoned, whose fuel is simultaneously transferred to some fellow
aircraft. The mission is considered as successful if  at least
one aircraft  finally reaches the target.


## Abstraction

We adopt the following abstractions in order to compute the sequence of actions needed by
the fleet to accomplish its mission. 


### Discrete Motion

For some arbitrary positive interger B, we take C/B liters as one unit of fuel
and take (RC)/B miles as one unit of distance, and say that an aircraft has a
maximum capacity of B units of fuel, and with which it can fly for B units of
distance at the most. We call B the _abstract capacity_ of an aircraft.

Moreover, we assume that an aircraft consumes fuel and covers distance in a discrete
(or unit-by-unit) and propotional manner, where one unit of fuel is consumed at
a time,  resulting in one unit of distance flied.

### Discrete Fuel Trasnfer 

Transfer of fuel within the fleet is also discrete:  only whole units
are allowed. For example, if an aircraft has 3 units of fuel left in the tank
that has a capacity of 5 units, then it can only refuel for 1 unit or 2 units.


## Remarks

Although the value of the abstract capacity B is arbitrarily picked, we must set it
to at least 2. If we set B = 1 then it would be impossible for the fleet to reach
the target (now B < D < NB), given our _discrete motion_ and _discrete fuel transfer_ assumptions.


For instance, B = 1 implies that the fleet would move forward for 1 unit of distance, 
running out of fuel and all aircraft abandoned.  If the fleet has two aircraft, and B = 2,
then there are  two possibilities:

1. The fleet flies for 2 units of distance, and then run out of fuel before reaching the target;
1. The fleet flies for 1 unit, then one aircraft is abandoned, transferring the fuel (1 unit) to the other, who
then continues to fly for 2 units. Thus the fleet achieves the range of 3 units.


## OCanren's Solution

Let B = 5 and OCanren suggested the following solutions
for fleets of various sizes to achieve certain ranges. In the
table, `Forward (x)` means that (all aircraft in) the fleet fly
forward for x units of distance; `Abandon([a1,...,an])` means that
 after abondoning one aircraft, the new state of the fleet is
`[a1,...,an]` where `a1,...,an` are fuel available for each aircraft
in the fleet and this takes into account of fuel transfer from the
single abandoned aircraft to the rest of the fleet. Without loss of generality, we always abandon the left
most aircraft in the list. It took about 10 mins to compute for the
6-aircraft fleet.

Fleet Size | Range | Moves
---        | ---   | ---
2          | 7     | [Forward (2); Abandon ([5]); Forward (5)] 
3          | 9     | [Forward (2); Abandon ([4; 5]); Forward (2); Abandon ([5]); Forward (5)] 
4          | 10    | [Forward (2); Abandon ([5; 4; 3]); Forward (1); Abandon ([4; 5]); Forward (2); Abandon ([5]); Forward (5)] 
5          | 11    | [Forward (1); Abandon ([5; 5; 5; 4]); Forward (1); Abandon ([5; 5; 5]); Forward (2); Abandon ([4; 5]); Forward (2); Abandon ([5]); Forward (5)] 
6          | 12    | [Forward (1); Abandon ([5; 5; 5; 5; 4]); Forward (1); Abandon ([5; 5; 5; 4]); Forward (1); Abandon ([5; 5; 5]); Forward (2); Abandon ([4; 5]); Forward (2); Abandon ([5]); Forward (5)]

## Reference

J. N. Franklin _[The Range of a Fleet of Aircraft](https://doi.org/10.1137/0108039)_
Journal of the Society for Industrial and Applied Mathematics, 8(3), 541–548. (8 pages) 


