open OCanren;;

(* types *)

module Ty = struct
  @type 'a t = O | S of 'a with show, gmap;;
  let fmap = fun f d -> GT.gmap(t) f d;;
end;;
  
include Ty;;

@type ground = ground t with show, gmap;;
@type logic = logic t OCanren.logic with show, gmap;;
type groundi = (ground, logic) injected;;

(* auxiliaries *)

module F = Fmap(Ty);;

let o = fun () -> inj @@ F.distrib O;;
let s = fun n  -> inj @@ F.distrib (S n);;

let rec groundi_of_int =
  function 0 -> o ()
         | n when n > 0 -> s (groundi_of_int (n - 1))
         | _ -> raise (Invalid_argument "groundi_of_int");;

let rec int_of_ground =
  function O -> 0
         | S n -> 1 + int_of_ground n;;

let rec int_of_logic =
  function Var _ -> raise Not_a_value
         | Value n ->
            begin
              match n with
                O -> 0
              | S m -> 1 + int_of_logic m
            end;;

let rec reify = fun env n -> F.reify reify env n;;

(* relations *)

let rec isp n = ocanren { n == O | fresh m in n == S m};; 

let rec lt a b =
  ocanren{ fresh n in
           b == S n &
             { a == O
             | fresh n' in
               a == S n'
               & lt n' n }};;

let lte a b = ocanren{ a == b | lt a b };;

let rec add a b c =
  ocanren{ a == O & b == c
         | fresh n, m in
           a == S n & c == S m & add n b m};;

let rec div a b q r =
  ocanren {fresh n in
           b == S n &
             {  lt a b  & q == O & r == a
             |  a == b  & q == S O & r == O
             |  lt b a
                & fresh c, q' in
                add b c a
                & add (S O) q' q
                & div c b q' r }};;

let rec gcd a b c = (* the Euclidean algorithm *)
  ocanren { { lte b a & fresh q in
              div a b q O & c == b }
          | { fresh q, n in
              lt b a
              & div a b q (S n)
              & gcd b (S n) c } };;

let gcd' a b c = 
  ocanren { fresh bnd in
            isp bnd
            & add a b bnd
            & gcd a b c };;

let simplify a b a' b' = 
      ocanren {  fresh n in b == S n &
      { a == O & a' == O & b' == S O
      | fresh c, m in a == S m
                      & div a c a' O
                      & div b c b' O
                      & gcd a b c } };;

let simplify' a b a' b' = 
      ocanren {  fresh n in b == S n &
      { a == O & a' == O & b' == S O
      | fresh c, m in a == S m
                      & gcd a b c
                      & div a c a' O
                      & div b c b' O  } };;

let coprime a b = simplify a b a b;;

let coprime' a b = ocanren { gcd' a b (S O) };;

(* redefine the "show" function for the logic Peano number type *)
let logic = {
  logic with
  GT.plugins =
    object(this)
      method gmap = logic.GT.plugins#gmap
      method show = fun ln ->
        try string_of_int @@ int_of_logic ln
        with Not_a_value ->
              let rec omit_var = function
                | Var _ -> 0
                | Value (S n) -> 1 + omit_var n
                | Value O -> assert false
              in
              let cn = omit_var ln in
              if cn  = 0 then "n" else string_of_int cn ^ "+n"
    end}
