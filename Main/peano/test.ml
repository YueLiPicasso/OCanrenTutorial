open OCanren;;
open Peano;;
  
let take = fun ?n s -> OCanren.Stream.take ?n s;;
let printf = Printf.printf;;

printf "###### test lt ######\n\n";;

printf "Checking\n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run one (fun q -> ocanren { lt O (S O) & lt (S O) (S(S O)) }) (fun q -> q#reify reify);;

let _ = Printf.printf "%d answer(s) found.\n" @@ List.length @@ take @@
          run one (fun q -> ocanren { lt (S O) O | lt (S(S O)) (S O) }) (fun q -> q#reify reify);;

printf "\n 5 is less than what ? \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run one (fun q -> ocanren { lt (S(S(S(S(S O))))) q }) (fun q -> q#reify reify);;

printf "\n What is less than 5 ? \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
          run one (fun q -> ocanren { lt q (S(S(S(S(S O))))) }) (fun q -> q#prj);;

printf "\n What is less than what ? \n\n";;

let _ =
  let printer =
    fun x,y -> print_endline @@ ("(" ^ GT.show(logic) x ^ " , " ^ GT.show(logic) y ^ ")")
  in List.iter printer
     @@ take ~n:10
     @@ run two (fun q r -> ocanren { lt q r }) (fun q r -> q#reify reify, r#reify reify);;

printf "\n###### test lte ######\n\n";;
   
printf "\n Checking \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run one
            (fun q -> ocanren { lte (S O) (S(S O)) & lte (S O) (S O) })
            (fun q -> q#reify reify);;

let _ = printf "%d answer(s) found.\n" @@ List.length @@ take @@
          run one
            (fun q -> ocanren { lte (S O) O | lte (S(S O)) (S O) })
            (fun q -> q#reify reify);;

   
printf "\n 5 is less than or equal to what ? \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run one (fun q -> ocanren { lte (S(S(S(S(S O))))) q }) (fun q -> q#reify reify);;

printf "\n What is less than or equal to 5 ? \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
          run one (fun q -> ocanren { lte q (S(S(S(S(S O))))) }) (fun q -> q#prj);;

printf "\n What is less than or equal to what ? \n\n";;

let _ =
  let printer =
    fun x,y -> print_endline @@ ("(" ^ GT.show(logic) x ^ " , " ^ GT.show(logic) y ^ ")")
  in List.iter printer
     @@ take ~n:10
     @@ run two (fun q r -> ocanren { lte q r }) (fun q r -> q#reify reify, r#reify reify);;

printf "\n###### test add ######\n\n";;
   
printf "\n Checking \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run one
            (fun q -> ocanren { add (S O) (S(S O)) (S(S(S O)))
                                & add (S O) (S O) (S(S O))})
            (fun q -> q#reify reify);;

let _ = printf "%d answer(s) found.\n" @@ List.length @@ take @@
          run one
            (fun q -> ocanren { add (S O) O O
                                    | add (S(S O)) (S O) (S O) })
            (fun q -> q#reify reify);;


printf "\n 3 adds 4 equals to what ? \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
          run one
            (fun q -> ocanren { add (S(S(S O))) (S(S(S(S O)))) q })
            (fun q -> q#prj);;


printf "\n 3 adds what equals to 7 ? \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
          run one
            (fun q -> ocanren { add (S(S(S O))) q (S(S(S(S(S(S(S O))))))) })
            (fun q -> q#prj);;


printf "\n What adds 4 equals to 7 ? \n\n";;

let _ = List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
          run one
            (fun q -> ocanren { add q (S(S(S(S O)))) (S(S(S(S(S(S(S O))))))) })
            (fun q -> q#prj);;


printf "\n What adds what equals to 7 ? \n\n";;

let _ =
  let printer =
    fun x,y -> print_endline @@ ("(" ^ GT.show(ground) x ^ " , " ^ GT.show(ground) y ^ ")")
  in List.iter printer
     @@ take 
     @@ run two (fun q r -> ocanren { add q r (S(S(S(S(S(S(S O))))))) })
          (fun q r -> q#prj, r#prj);;


let _ =
  let ans_no = 10 in
  printf "\n What adds 4 equals to what ? (Give %d answers) \n\n" ans_no;
  let printer =
    fun x,y -> print_endline @@ ("(" ^ GT.show(ground) x ^ " , " ^ GT.show(ground) y ^ ")")
  in List.iter printer
     @@ take ~n:ans_no
     @@ run two (fun q r -> ocanren { add q  (S(S(S(S O)))) r })
          (fun q r -> q#prj, r#prj);;


printf "\n 3 adds what equals to what ? \n\n";;

let _ =
  let printer =
    fun x,y -> print_endline @@ ("(" ^ GT.show(logic) x ^ " , " ^ GT.show(logic) y ^ ")")
  in List.iter printer
     @@ take 
     @@ run two (fun q r -> ocanren { add (S(S(S O))) q r })
          (fun q r -> q#reify reify, r#reify reify);;


let _ =
  let ans_no = 10 in
  printf "\n What adds what equals to what ? (Give %d answers) \n\n" ans_no;
  let module M = struct @type t = ground * logic * logic with show end in
  let printer = fun t3 -> print_endline @@ GT.show(M.t) t3  in
  List.iter printer
  @@ take ~n:ans_no
  @@ run three
       (fun a b c -> ocanren { add a b c })
       (fun a b c -> a#prj, b#reify reify, c#reify reify);;


printf "\n###### test div ######\n\n";;
   
printf "\n Checking \n\n";;

let p17 = groundi_of_int 17;;

let _ =
  List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
    run one (fun q -> ocanren { div p17 (S(S(S O))) (S(S(S(S(S O))))) (S(S O))})
      (fun q -> q#reify reify);;

let _ =
  List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
    run one (fun q -> ocanren { div (S O) p17 O (S O) })
      (fun q -> q#reify reify);;


let _ = printf "%d answer(s) found.\n" @@ List.length @@ take @@
          run one
            (fun q -> ocanren { div (S O) O O (S O) | div (S O) (S(S O)) (S O) O })
            (fun q -> q#reify reify);;

(* one unknown *)
printf "\n 17 divided by 5 equals 3 with remainder what ? \n\n";;

let _ =
  List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
    run one (fun q -> ocanren { div p17 (S(S(S(S(S O))))) (S(S(S O))) q })
      (fun q -> q#prj);;

printf "\n 17 divided by 5 equals what with remainder 2 ?  \n\n";;

let _ =
  List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
    run one (fun q -> ocanren { div p17 (S(S(S(S(S O))))) q (S(S(O))) })
      (fun q -> q#prj);;


printf "\n 17 divided by what equals 3 with remainder 2? \n\n";;

let _ =
  List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
    run one (fun q -> ocanren { div p17 q (S(S(S O))) (S(S O)) })
      (fun q -> q#prj);;


printf "\n What divided by 5 equals 3 with remainder 2? \n\n";;

let _ =
  List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
    run one (fun q -> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) (S(S O)) })
      (fun q -> q#prj);;


(* use div for multiplication *)
printf "\n What divided by 5 equals 3 with remainder 0 ? \n\n";;

let _ =
  List.iter (fun x -> print_endline @@ GT.show(ground) x) @@ take @@
    run one (fun q -> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) O })
      (fun q -> q#prj);;


(* two unknowns *)
let _ =
  let ans_no = 10 in
  let printer = fun x,y -> print_endline @@
                             ((string_of_int @@ int_of_ground x)
                              ^ ", "
                              ^ (string_of_int @@ int_of_ground y))
  in
  printf "\n What divided by what equals 3 with remainder 2 ? (Give %d answers) \n\n" ans_no;
  List.iter  printer @@ take ~n:ans_no @@
    run two (fun q r-> ocanren { div q r (S(S(S O))) (S(S O)) })
      (fun q r-> q#prj, r#prj);
  printf "\n What divided by 5 equals what with remainder 2 ? (Give %d answers)\n\n" ans_no;
  List.iter  printer @@ take ~n:ans_no @@
    run two (fun q r-> ocanren { div q (S(S(S(S(S O))))) r (S(S O)) })
      (fun q r-> q#prj, r#prj);
  printf "\n What divided by 5 equals 3 with remainder what ? (Give all answers)\n\n";
  List.iter  printer @@ take @@
    run two (fun q r-> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) r })
      (fun q r-> q#prj, r#prj);
  printf "\n 17 divided by what equals what with remainder 2 ? (Give all answers) \n\n";
  List.iter  printer @@ take @@
    run two (fun q r-> ocanren { div p17 q r (S(S O)) })
      (fun q r-> q#prj, r#prj);
  printf "\n 17 divided by what equals 3 with remainder what ? (Give all answers)\n\n";
  List.iter  printer @@ take @@
    run two (fun q r-> ocanren { div p17 q (S(S(S O))) r })
      (fun q r-> q#prj, r#prj);
  printf "\n 17 divided by 5 equals what with remainder what ? \n\n";
  List.iter  printer @@ take @@
    run two (fun q r-> ocanren { div p17 (S(S(S(S(S O))))) q  r })
      (fun q r-> q#prj, r#prj);
  (* three unknowns *)
  let module M = struct @type t = logic * logic * logic with show end in
  let printer = fun t3 -> print_endline @@ GT.show(M.t) t3 in
  printf "\n 17 divided by what equals what with remainder what? (Give all answers)\n\n" ;
  List.iter  printer @@ take @@
    run three (fun a b c -> ocanren { div p17 a b c })
      (fun a b c-> a#reify reify, b#reify reify, c#reify reify);
  let ans_no = 60 in
  printf "\n What divided by 5 equals what with remainder what? (Give %d answers)\n\n" ans_no;
  let printer = fun x,y,z -> print_endline @@
                             ((string_of_int @@ int_of_ground x)
                              ^ ", "
                              ^ (string_of_int @@ int_of_ground y)
                              ^ ", "
                              ^ (string_of_int @@ int_of_ground z))
  in
  List.iter printer @@ take ~n:ans_no @@
    run three (fun a b c -> ocanren { div a (S(S(S(S(S O))))) b c })
      (fun a b c-> a#prj, b#prj, c#prj);
  printf "\n What divided by what equals 3 with remainder what? (Give %d answers)\n\n" ans_no;
  List.iter printer @@ take ~n:ans_no @@
    run three (fun a b c -> ocanren { div a b (S(S(S O))) c })
      (fun a b c-> a#prj, b#prj, c#prj);
  printf "\n What divided by what equals what with remainder 2? (Give %d answers)\n\n" ans_no;
  let printer = fun t3 -> print_endline @@ GT.show(M.t) t3 in
  List.iter printer @@ take ~n:1 @@
    run three (fun a b c -> ocanren { div a b c (S(S O)) })
      (fun a b c-> a#reify reify, b#reify reify, c#reify reify);
  let printer = fun x,y,z -> print_endline @@
                             ((string_of_int @@ int_of_logic x)
                              ^ ", "
                              ^ (string_of_int @@ int_of_logic y)
                              ^ ", "
                              ^ (string_of_int @@ int_of_logic z))
  in
  List.iter printer @@ List.tl @@ take ~n:ans_no @@
    run three (fun a b c -> ocanren { div a b c (S(S O)) })
       (fun a b c-> a#reify reify, b#reify reify, c#reify reify);
  (* four unknowns *)
  printf "\n What divided by what equals what with remainder what? \n\n";
  let module M = struct @type t = logic * logic * logic * logic with show end in
  let printer = fun t4 -> print_endline @@ GT.show(M.t) t4 in
  List.iter printer @@ take ~n:ans_no @@
    run four (fun a b c d -> ocanren { div a b c d })
      (fun a b c d -> a#reify reify, b#reify reify, c#reify reify, d#reify reify);;
  
  
