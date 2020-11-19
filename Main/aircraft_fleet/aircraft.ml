open GT;;
module L = Stdlib.List;;
open OCanren;;
open OCanren.Std;;


@type unitt = int with show;;

@type fuel = unitt with show;;

(* position of the fleet *)

@type pos  = unitt with show;;

(* list the amount of fuel in each aircraft of the fleet *)

@type fuel_profile = fuel GT.list with show;;

(* the state of the fleet *)

@type state = pos * fuel_profile with show;;

@type ('pos, 'fuel_profile) action =
     Forward of 'pos
   | Abandon of 'fuel_profile (* post-abandoning profile  *)
 with show, gmap;;

(* data injection primitives *)

module Action : sig
  val forward :
    ('a, 'b) injected ->
    (('a, 'c) action, ('b, 'd) action logic) injected
  val abandon :
    ('a, 'b) injected ->
    (('c, 'a) action, ('d, 'b) action logic) injected
end = struct

  module T = struct
    type ('a,'b) t = ('a,'b) action;;
    let fmap = fun x -> gmap(action) x;;
  end;;
  
  module F = Fmap2(T);;

  let distrib_inj x = inj @@ F.distrib x;;

  let forward x = distrib_inj (Forward x);;
  let abandon x = distrib_inj (Abandon x);;
 
end;;

(* substract an amount amt from all members of fl, resulting in fl' *)

let rec subtract_all amt fl fl' =
  let open Nat in 
  ocanren {
    fl == [] & fl' == [] |
    fresh h, t, h', t' in
     fl == h :: t      &
     fl' == h' :: t'   &
     (+) amt h' h      &
     subtract_all amt t t'
};;

(* capacity of each aircraft *)

let tank_capacity = nat 5;;

(* Some amount amt of fuel is given to and shared among the fleet, 
   changing the fleet's fuel profile from fl to fl'. *)

let rec share_fuel amt fl fl' =
  let open Nat in
  ocanren {
    fl == [] & fl' == []   |
    fresh amta, amtb in
     (+) amta amtb amt     &
      fresh h, t, h',t' in
       fl  == h  :: t      &
       fl' == h' :: t'     &
       (+) h amta h'       &
       h' <= tank_capacity &
       share_fuel amtb t t'
};;

(* abandon one aircraft and transfer its fuel to the rest 
   of the fleet *)

let abandono fl fl' =
  ocanren {
    fl == [] & fl' == [] |
    fresh h, t in
     fl == h :: t        &
     share_fuel h t fl'
};;

(* postive natural number *)

let positive x = ocanren { fresh n in x == Nat.succ n };;

(* check a list is not empty *)

let non_empty l = ocanren { fresh h,t in  l == h :: t };;

(* single step state transition  *)

let step pre_state action post_state =
  let open Action in
  let open Nat in
  ocanren {
    fresh p, l in (* p: position; l:fuel profile *)
      pre_state == (p, l)      &
      { fresh d    ,   (* d    : distance forward *)
              p'   ,   (* p'   : position after forward *)
              l'       (* l'   : updated fuel list *)
        in 
          action == Forward d  &
          positive d           &
          d <= tank_capacity   &
          non_empty l          &
          subtract_all d l l'  &
          (+) d p p'           &
          post_state == (p', l')

       | fresh l' in (* updated fuel profile *)
          action == Abandon l' &
          abandono l l' &
          post_state == (p, l')
       }
};;

(* helper relation to ensure alternating actions: 
   every action act is given a unique code co  *)

let kind act co =
  let open Action in
  ocanren {
    fresh x, y in
     act == Forward x & co == !(!!0)
   | act == Abandon y & co == !(!!1)
};;

(* sequencing multiple steps *)
module Steps = struct

let rec steps co pre acts post =
  ocanren {
    acts == [] & pre == post |
    fresh mid, hact, tact, co' in
     acts == hact :: tact &
     kind hact co'        &
     co =/= co'           &
     step pre hact mid    &
     steps co' mid tact post
};;

end;;

let steps pre acts post = Steps.steps !!2 pre acts post;;

(* test the helpers *)

let fuel_profile_printer r =
  let convert = List.to_list Nat.to_int in
  L.iter (fun x -> print_string x;print_newline()) @@
  L.map (fun x -> show(fuel_profile) @@ convert x) @@ Stream.take @@ r
in
Printf.printf "subtract_all\n\n";
fuel_profile_printer @@
run q (fun q -> ocanren { subtract_all 3 [3;4;5;6;7;8;9] q } ) project;
fuel_profile_printer @@
run q (fun q -> ocanren { subtract_all 7 [3;4;5;6;7;8;9] q } ) project;
fuel_profile_printer @@
run q (fun q -> ocanren { subtract_all 2 [3;4;5;6;7;8;9] q } ) project;
Printf.printf "\nshare_fuel\n\n";
fuel_profile_printer @@
run q (fun q -> ocanren { share_fuel 2 [1;1;1;2;3;4] q } ) project;
fuel_profile_printer @@
run q (fun q -> ocanren { share_fuel 4 [4;4;4] q } ) project;
Printf.printf "\nabandono\n\n";
fuel_profile_printer @@
run q (fun q -> ocanren { abandono [4;4;4;4] q } ) project;
fuel_profile_printer @@
run q (fun q -> ocanren { abandono [] q } ) project;
fuel_profile_printer @@
run q (fun q -> ocanren { abandono [3;1;1;1;1;1] q } ) project;;

(* initialize arbitrarily-sized fleet *)

let init_fleet n =
  let l = List.list (L.init n (fun _ -> tank_capacity))
  and p = nat 0 in
  Pair.pair p l;; 

(* some initial states of the fleet *)

let init_two    = init_fleet 2
and init_three  = init_fleet 3
and init_four   = init_fleet 4
and init_five   = init_fleet 5
and init_six    = init_fleet 6;;

(* reification primitives *)

let prj_actions ls : (pos, fuel_profile) action GT.list =
  List.to_list (gmap(action) Nat.to_int (List.to_list Nat.to_int)) (project ls);;

let prj_state x : state =
  match project x with  (p,l) -> Nat.to_int p, (List.to_list Nat.to_int l);;

(* type abbreviation for pretty-printing *)

@type ('a,'b) actions = ('a,'b) action GT.list with show;;

let print_solution x =
  let print_actions_state (acts, stas) =
    Printf.printf "The actions are : \n %s \n The final state is : %s\n%!" acts stas
  and
    actions_state_to_string (al, st) =
    let showpos = show(pos) and showfuel = show(fuel_profile) in
    show(actions) showpos showfuel al, show(state) st
  in
  L.iter print_actions_state @@ L.map actions_state_to_string @@ Stream.take ~n:1 @@ x (* try ~n:4 *)
in 
print_solution @@
  run qr (fun q r -> ocanren { fresh fp in r == (7, fp) & steps init_two q r })  
         (fun qs rs -> prj_actions qs, prj_state rs);
print_solution @@
  run qr (fun q r -> ocanren { fresh fp in r == (9, fp) & steps init_three q r })  
         (fun qs rs -> prj_actions qs, prj_state rs);
print_solution @@
  run qr (fun q r -> ocanren { fresh fp in r == (10, fp) & steps init_four q r })  
         (fun qs rs -> prj_actions qs, prj_state rs);
print_solution @@
  run qr (fun q r -> ocanren { fresh fp in r == (11, fp) & steps init_five q r })
(fun qs rs -> prj_actions qs, prj_state rs);
print_solution @@
  run qr (fun q r -> ocanren { fresh fp in r == (12, fp) & steps init_six q r })
(fun qs rs -> prj_actions qs, prj_state rs);;

