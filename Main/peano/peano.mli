open OCanren;;

@type 'a t = O | S of 'a with show, gmap;;

@type ground = ground t with show, gmap;;

@type logic = logic t OCanren.logic with show, gmap;;

type groundi = (ground, logic) injected;;

val o : unit -> groundi;;

val s : groundi -> groundi;;

val reify : VarEnv.t -> groundi -> logic;;

val lt : groundi -> groundi -> goal;;
(** [lt a b] : a is less than b *)

val lte : groundi -> groundi -> goal;;
(** [lte a b] : a is less than or equal to b *)

val add : groundi -> groundi -> groundi -> goal;;
(** [add a b c] : a plus b equals c *)

val div : groundi -> groundi -> groundi -> groundi -> goal;;
(** [div a b q r] : dividing a by b gives quotient q and remainder r *)

val gcd : groundi -> groundi -> groundi -> goal;;
(** [gcd a b c] : if the greatest common divisor of a and b is c, where a is no less than  b *)

val lcm : groundi -> groundi -> groundi -> goal;;
(** [lcm a b c] : if the least common multiple of a and b is c, where a is no less than  b *)


