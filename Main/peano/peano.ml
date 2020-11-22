open OCanren;;

module Ty = struct
  @type 'a t = O | S of 'a with show, gmap;;
  let fmap = fun f d -> GT.gmap(t) f d;;
end;;
  
module F = Fmap(Ty);;

include Ty;;

@type ground = ground t with show, gmap;;
@type logic = logic t OCanren.logic with show, gmap;;
type groundi = (ground, logic) injected;;

let o = fun () -> inj @@ F.distrib O;;
let s = fun n  -> inj @@ F.distrib (S n);;

let rec reify = fun env n -> F.reify reify env n;;

let rec lt a b =
  ocanren{ fresh n in b == S n &
                        { a == O
                        | fresh n' in a == S n' & lt n' n }};;

let rec add a b c =
  ocanren{ a == O & b == c
         | fresh n, m in
           a == S n & c == S m & add n b m};;

let rec div a b q r =
  ocanren {fresh n in
           b == S n &
             {  lt a b  & q == O & r == a
             |  a == b  & q == S O & r == O
             |  lt b a  & fresh c, q' in add b c a & add (S O) q' q & div c b q' r }};;


