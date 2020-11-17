module MyLogic = struct
  type 'a logic = Value of 'a | Var of int * 'a logic list
  type ('a, 'b) injected 
end;;

open MyLogic;;

module MyList = struct
  type ('a, 'b) t = Nil | Cons of 'a * 'b
  type 'a ground = ('a, 'a ground) t
  type 'b logic   =  ('b, 'b logic) t MyLogic.logic
  type ('a, 'b) groundi = ('a ground, 'b logic) injected
end;;

module Peano = struct
  type 'a t   = O | S of 'a
  type ground = ground t
  type logic  =  logic t MyLogic.logic
  type groundi = (ground, logic) injected
end;;

module MyPair = struct
  type ('a1, 'a2) t = 'a1 * 'a2
  type ('a1, 'a2) ground = ('a1, 'a2) t
  type ('b1, 'b2) logic =  ('b1, 'b2) t MyLogic.logic
  type ('a1, 'a2, 'b1, 'b2) groundi = (('a1, 'a2) ground, ('b1, 'b2) logic) injected
end;;

module PP = struct
   type ground = (Peano.ground, Peano.ground) MyPair.ground;;
   type logic = (Peano.logic, Peano.logic) MyPair.logic;;
   type groundi = (Peano.ground, Peano.ground, Peano.logic, Peano.logic) MyPair.groundi;;
end;;

module PPL = struct
  type ground = (Peano.ground, Peano.ground MyList.ground) MyPair.ground;;
  type logic  = (Peano.logic,  Peano.logic MyList.logic) MyPair.logic;;
  type groundi = (* = (ground, logic) injected *)
    (Peano.ground,
     Peano.ground MyList.ground,
     Peano.logic,
     Peano.logic MyList.logic) MyPair.groundi;;
end;;

open MyList;;
open Peano;;
   
let _ = ( Value Nil                                       : Peano.logic MyList.logic );; 
let _ = ( Value (Cons (Value (S (Value O)) , Value Nil))  : Peano.logic MyList.logic );;
let _ = ( Value (Cons (Var (1,[]), Value Nil))            : Peano.logic MyList.logic );;
let _ = ( Value (Cons (Value (S (Value O)) , Var (2,[]))) : Peano.logic MyList.logic );;
let _ = ( Value (Cons (Var (1,[]), Var (2,[])))           : Peano.logic MyList.logic );;
let _ = ( Var (1,[])                                      : Peano.logic MyList.logic );;

let _ = ( Var (1,[])                                      : PP.logic );;
let _ = ( Value (Var (1,[]), Value (S (Var (1, []))))     : PP.logic );;
let _ = ( Value (Var (1,[]), Var (1, []))                 : PP.logic );;
let _ = ( Value (Value O, Value (S (Value O)))            : PP.logic );;

let _ = ( Var (1,[])                                                            : PPL.logic );;
let _ = ( Value (Var (1,[]), Var (2, []))                                       : PPL.logic );;
let _ = ( Value (Var (1,[]), Value (Cons (Value (S (Var (2, []))), Value Nil))) : PPL.logic );;



