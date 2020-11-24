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

let rec reify = fun env n -> F.reify reify env n;;

(* relations *)

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

let rec gcd a b c = (* by Euclidean algorithm *)
  ocanren { { lte b a & fresh q in
              div a b q O & c == b }
          | lt b a & fresh q, n in
            div a b q (S n)
            & gcd b (S n) c };;

let lcm a b c =
  ocanren { fresh ab, g in
            div ab a b O
            & gcd a b g
            & div ab c g O };;

let simplify a b a' b'= 
      ocanren {  fresh n in b == S n &
      {  a == O  & a' == O & b' == S O
      |  fresh c, m in a == S m
                       & div a c a' O
                       & div b c b' O
                       & gcd a b c } };;
