open OCanren;;

(** types *)

@type 'a t = O | S of 'a with show, gmap;;
(** The abstract type *)

@type ground = ground t with show, gmap;;
(** ground Peano  *)

@type logic = logic t OCanren.logic with show, gmap;;
(** logic Peano *)

type groundi = (ground, logic) injected;;
(** injected Peano *)

(** Auxiliaries *)

val o : unit -> groundi;;
(** injection function for O *)

val s : groundi -> groundi;;
(** injection function for S *)

val groundi_of_int : int -> groundi;;
(** type conversion *)

val int_of_ground : ground -> int;;
(** type conversion *)

val int_of_logic : logic -> int;;
(** type conversion: raises exception Not_a_value if there is a free logic variable *)

val reify : VarEnv.t -> groundi -> logic;;
(** reifier *)

(** Relations *)

val lt : groundi -> groundi -> goal;;
(** [lt a b] : a is less than b *)

val lte : groundi -> groundi -> goal;;
(** [lte a b] : a is less than or equal to b *)

val add : groundi -> groundi -> groundi -> goal;;
(** [add a b c] : a plus b equals c *)

val div : groundi -> groundi -> groundi -> groundi -> goal;;
(** [div a b q r] : dividing a by b gives quotient q and remainder r *)

val gcd : groundi -> groundi -> groundi -> goal;;
(** [gcd a b c] : the greatest common divisor of a and b is c, where a is no less than  b *)

val gcd' : groundi -> groundi -> groundi -> goal;;
(** declaratively the same as [gcd], but has a different search strategy  *)

val lcm : groundi -> groundi -> groundi -> goal;;
(** [lcm a b c] : the least common multiple of a and b is c, where a is no less than  b *)

val simplify : groundi -> groundi -> groundi -> groundi -> goal;;
(** [simplify a b a' b'] : if the simplest form of the ratio a/b is a'/b' *)

