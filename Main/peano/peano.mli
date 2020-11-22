open OCanren;;

@type 'a t = O | S of 'a with show, gmap;;

@type ground = ground t with show, gmap;;

@type logic = logic t OCanren.logic with show, gmap;;

type groundi = (ground, logic) injected;;

val o : unit -> groundi;;

val s : groundi -> groundi;;

val reify : VarEnv.t -> groundi -> logic;;

val lt : groundi -> groundi -> goal;;

val add : groundi -> groundi -> groundi -> goal;;

val div : groundi -> groundi -> groundi -> groundi -> goal;;
