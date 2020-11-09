module MyLogic = struct
  type 'a logic = Value of 'a | Var of int * 'a logic list
  type ('a, 'b) injected 
end;;

module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b
  type 'a ground = ('a, 'a ground) t
  type 'b logic   =  ('b, 'b logic) t MyLogic.logic
  type ('a, 'b) groundi = ('a ground, 'b logic) MyLogic.injected
end;;

module Peano = struct
  type 'a t   = O | S of 'a
  type ground = ground t
  type logic  =  logic t MyLogic.logic
  type groundi = (ground, logic) MyLogic.injected
end;;
