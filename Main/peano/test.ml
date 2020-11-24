open OCanren;;
open Peano;;

let printf = Printf.printf;;
let take ?n s = OCanren.Stream.take ?n s;;

let printer1 = fun x -> print_endline @@ GT.show(logic) x
and printer2 = fun x -> let module M = struct @type t = logic * logic with show end in
                        print_endline @@ GT.show(M.t) x
and printer3 = fun x -> let module M = struct @type t = logic * logic * logic with show end in
                        print_endline @@ GT.show(M.t) x
and printer4 = fun x -> let module M =
                          struct
                            @type t = logic * logic  * logic * logic with show
                          end in
                        print_endline @@ GT.show(M.t) x;;

let reify1 = fun q -> q#reify reify
and reify2 = fun q r -> q#reify reify, r#reify reify
and reify3 = fun a b c -> a#reify reify, b#reify reify, c#reify reify
and reify4 = fun a b c d -> a#reify reify, b#reify reify, c#reify reify, d#reify reify;;

let iterp1 ?n s =  List.iter printer1 @@ OCanren.Stream.take ?n s
and iterp2 ?n s =  List.iter printer2 @@ OCanren.Stream.take ?n s
and iterp3 ?n s =  List.iter printer3 @@ OCanren.Stream.take ?n s
and iterp4 ?n s =  List.iter printer4 @@ OCanren.Stream.take ?n s;;

let run1 = fun g -> run one g reify1;;
(* TO do: add run2-4 *)
  
printf "###### test lt ######\n\n";;

let _ =
  printf "Checking\n\n";
  iterp1 @@
    run1 (fun q -> ocanren { lt O (S O) & lt (S O) (S(S O)) });
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run1 (fun q -> ocanren { lt (S O) O | lt (S(S O)) (S O) }) ;
  printf "\n 5 is less than what ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { lt (S(S(S(S(S O))))) q }) ;
  printf "\n What is less than 5 ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { lt q (S(S(S(S(S O))))) }) ;
  printf "\n What is less than what ? \n\n";
  iterp2 ~n:10 @@
    run two (fun q r -> ocanren { lt q r }) reify2;;

printf "\n###### test lte ######\n\n";;

let _ =
  printf "\n Checking \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { lte (S O) (S(S O)) & lte (S O) (S O) }) ;
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run1 (fun q -> ocanren { lte (S O) O | lte (S(S O)) (S O) }) ;
  printf "\n 5 is less than or equal to what ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { lte (S(S(S(S(S O))))) q }) ;
  printf "\n What is less than or equal to 5 ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { lte q (S(S(S(S(S O))))) }) ;
  printf "\n What is less than or equal to what ? \n\n";
  iterp2 ~n:10 @@ run two (fun q r -> ocanren { lte q r })reify2;;

printf "\n###### test add ######\n\n";;

let _ =
  printf "\n Checking \n\n";
  iterp1 @@
    run one (fun q -> ocanren { add (S O) (S(S O)) (S(S(S O)))
                                & add (S O) (S O) (S(S O))}) reify1;
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run one
      (fun q -> ocanren { add (S O) O O | add (S(S O)) (S O) (S O) }) reify1;
  printf "\n 3 adds 4 equals to what ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { add (S(S(S O))) (S(S(S(S O)))) q }) ;
  printf "\n 3 adds what equals to 7 ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { add (S(S(S O))) q (S(S(S(S(S(S(S O))))))) }) ;
  printf "\n What adds 4 equals to 7 ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { add q (S(S(S(S O)))) (S(S(S(S(S(S(S O))))))) }) ;
  printf "\n What adds what equals to 7 ? \n\n";
  iterp2 @@
    run two (fun q r -> ocanren { add q r (S(S(S(S(S(S(S O))))))) }) reify2;
  let ans_no = 10 in
  printf "\n What adds 4 equals to what ? (Give %d answers) \n\n" ans_no;
  iterp2 ~n:ans_no @@
    run two (fun q r -> ocanren { add q  (S(S(S(S O)))) r }) reify2;
  printf "\n 3 adds what equals to what ? \n\n";
  iterp2 @@
    run two (fun q r -> ocanren { add (S(S(S O))) q r }) reify2;
  printf "\n What adds what equals to what ? (Give %d answers) \n\n" ans_no;
  iterp3 ~n:ans_no @@
    run three (fun a b c -> ocanren { add a b c }) reify3;;


printf "\n###### test div ######\n\n";;
   
printf "\n Checking \n\n";;

let _ =
  let p17 = groundi_of_int 17 in
  iterp1 @@
    run1 (fun q -> ocanren { div p17 (S(S(S O))) (S(S(S(S(S O))))) (S(S O))}) ;
  iterp1 @@
    run1 (fun q -> ocanren { div (S O) p17 O (S O) }) ;
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run1 (fun q -> ocanren { div (S O) O O (S O) | div (S O) (S(S O)) (S O) O }) ;
  (* one unknown *)
  printf "\n 17 divided by 5 equals 3 with remainder what ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { div p17 (S(S(S(S(S O))))) (S(S(S O))) q }) ;
  printf "\n 17 divided by 5 equals what with remainder 2 ?  \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { div p17 (S(S(S(S(S O))))) q (S(S(O))) }) ;
  printf "\n 17 divided by what equals 3 with remainder 2? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { div p17 q (S(S(S O))) (S(S O)) }) ;
  printf "\n What divided by 5 equals 3 with remainder 2? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) (S(S O)) }) ;
  (* use div for multiplication *)
  printf "\n What divided by 5 equals 3 with remainder 0 ? \n\n";
  iterp1 @@
    run1 (fun q -> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) O });
  (* two unknowns *)  
  let ans_no = 10 in
  printf "\n What divided by what equals 3 with remainder 2 ? (Give %d answers) \n\n" ans_no;
  iterp2 ~n:ans_no @@
    run two (fun q r-> ocanren { div q r (S(S(S O))) (S(S O)) }) reify2;
  printf "\n What divided by 5 equals what with remainder 2 ? (Give %d answers)\n\n" ans_no;
  iterp2 ~n:ans_no @@
    run two (fun q r-> ocanren { div q (S(S(S(S(S O))))) r (S(S O)) }) reify2;
  printf "\n What divided by 5 equals 3 with remainder what ? (Give all answers)\n\n";
  iterp2 @@
    run two (fun q r-> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) r }) reify2;
  printf "\n 17 divided by what equals what with remainder 2 ? (Give all answers) \n\n";
  iterp2 @@
    run two (fun q r-> ocanren { div p17 q r (S(S O)) }) reify2;
  printf "\n 17 divided by what equals 3 with remainder what ? (Give all answers)\n\n";
  iterp2 @@
    run two (fun q r-> ocanren { div p17 q (S(S(S O))) r }) reify2;
  printf "\n 17 divided by 5 equals what with remainder what ? \n\n";
  iterp2 @@
    run two (fun q r-> ocanren { div p17 (S(S(S(S(S O))))) q  r }) reify2;
  (* three unknowns *)
  printf "\n 17 divided by what equals what with remainder what? (Give all answers)\n\n" ;
  iterp3 @@
    run three (fun a b c -> ocanren { div p17 a b c })
     reify3;
  let ans_no = 60 in
  printf "\n What divided by 5 equals what with remainder what? (Give %d answers)\n\n" ans_no;
  iterp3 ~n:ans_no @@
    run three (fun a b c -> ocanren { div a (S(S(S(S(S O))))) b c }) reify3;
  printf "\n What divided by what equals 3 with remainder what? (Give %d answers)\n\n" ans_no;
  iterp3 ~n:ans_no @@
    run three (fun a b c -> ocanren { div a b (S(S(S O))) c }) reify3;
  printf "\n What divided by what equals what with remainder 2? (Give %d answers)\n\n" ans_no;
  iterp3 ~n:ans_no @@
    run three (fun a b c -> ocanren { div a b c (S(S O)) }) reify3;
  (* four unknowns *)
  printf "\n What divided by what equals what with remainder what? \n\n";
  iterp4 ~n:ans_no @@
    run four (fun a b c d -> ocanren { div a b c d }) reify4;;
  
  
