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

module MyPair = struct
  type ('a1, 'a2) t = 'a1 * 'a2
  type ('a1, 'a2) ground = ('a1, 'a2) t
  type ('b1, 'b2) logic =  ('b1, 'b2) t MyLogic.logic
  type ('a1, 'a2, 'b1, 'b2) groundi = (('a1, 'a2) ground, ('b1, 'b2) logic) MyLogic.injected
end;;
