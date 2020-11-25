open OCanren;;
open Peano;;

let printf = Printf.printf;;

let take ?n s = OCanren.Stream.take ?n s;;

let printer1 = fun x -> print_endline @@ GT.show(logic) x
                      
and printer2 = fun x -> let module M = struct @type t = logic * logic with show end
                        in print_endline @@ GT.show(M.t) x
                        
and printer3 = fun x -> let module M = struct @type t = logic * logic * logic with show end
                        in print_endline @@ GT.show(M.t) x
                        
and printer4 = fun x -> let module M = struct @type t = logic * logic  * logic * logic with show end
                        in print_endline @@ GT.show(M.t) x;;

let reify1 = fun q       -> q#reify reify
and reify2 = fun q r     -> q#reify reify, r#reify reify
and reify3 = fun a b c   -> a#reify reify, b#reify reify, c#reify reify
and reify4 = fun a b c d -> a#reify reify, b#reify reify, c#reify reify, d#reify reify;;

let iterp1 ?n s =  List.iter printer1 @@ OCanren.Stream.take ?n s
and iterp2 ?n s =  List.iter printer2 @@ OCanren.Stream.take ?n s
and iterp3 ?n s =  List.iter printer3 @@ OCanren.Stream.take ?n s
and iterp4 ?n s =  List.iter printer4 @@ OCanren.Stream.take ?n s;;

let run1 = fun g -> run one   g reify1
and run2 = fun g -> run two   g reify2
and run3 = fun g -> run three g reify3
and run4 = fun g -> run four  g reify4;;

let ocrun1 = fun ?n g -> iterp1 ?n @@ run1 g
and ocrun2 = fun ?n g -> iterp2 ?n @@ run2 g
and ocrun3 = fun ?n g -> iterp3 ?n @@ run3 g
and ocrun4 = fun ?n g -> iterp4 ?n @@ run4 g;;

  
printf "###### test lt ######\n\n";;

let _ =
  (* checking *)
  printf "Checking\n\n";
  ocrun1 (fun q -> ocanren { lt O (S O) & lt (S O) (S(S O)) });
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run1 (fun q -> ocanren { lt (S O) O | lt (S(S O)) (S O) }) ;
  (* one unknown *)
  printf "\n 5 is less than what ? \n\n";
  ocrun1 (fun q -> ocanren { lt (S(S(S(S(S O))))) q });
  printf "\n What is less than 5 ? \n\n";
  ocrun1 (fun q -> ocanren { lt q (S(S(S(S(S O))))) });
  (* two unknowns *)
  printf "\n What is less than what ? \n\n";
  ocrun2 ~n:10 (fun q r -> ocanren { lt q r });;

printf "\n###### test lte ######\n\n";;

let _ =
  (* checking *)
  printf "\n Checking \n\n";
  ocrun1 (fun q -> ocanren { lte (S O) (S(S O)) & lte (S O) (S O) });
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run1 (fun q -> ocanren { lte (S O) O | lte (S(S O)) (S O) }) ;
  (* one unknown *)
  printf "\n 5 is less than or equal to what ? \n\n";
  ocrun1 (fun q -> ocanren { lte (S(S(S(S(S O))))) q });
  printf "\n What is less than or equal to 5 ? \n\n";
  ocrun1 (fun q -> ocanren { lte q (S(S(S(S(S O))))) });
  (* two unknowns *)
  printf "\n What is less than or equal to what ? \n\n";
  ocrun2 ~n:10 (fun q r -> ocanren { lte q r });;

printf "\n###### test add ######\n\n";;

let _ =
  (* checking *)
  printf "\n Checking \n\n";
  ocrun1 (fun q -> ocanren { add (S O) (S(S O)) (S(S(S O))) & add (S O) (S O) (S(S O))});
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run1  (fun q -> ocanren { add (S O) O O | add (S(S O)) (S O) (S O) });
  (* one unknown *)
  printf "\n 3 adds 4 equals to what ? \n\n";
  ocrun1 (fun q -> ocanren { add (S(S(S O))) (S(S(S(S O)))) q });
  printf "\n 3 adds what equals to 7 ? \n\n";
  ocrun1 (fun q -> ocanren { add (S(S(S O))) q (S(S(S(S(S(S(S O))))))) });
  printf "\n What adds 4 equals to 7 ? \n\n";
  ocrun1 (fun q -> ocanren { add q (S(S(S(S O)))) (S(S(S(S(S(S(S O))))))) });
  (* two unknowns *)
  printf "\n What adds what equals to 7 ? \n\n";
  ocrun2 (fun q r -> ocanren { add q r (S(S(S(S(S(S(S O))))))) });
  let ans_no = 10 in
  printf "\n What adds 4 equals to what ? (Give %d answers) \n\n" ans_no;
  ocrun2 ~n:ans_no (fun q r -> ocanren { add q  (S(S(S(S O)))) r });
  printf "\n 3 adds what equals to what ? \n\n";
  ocrun2 (fun q r -> ocanren { add (S(S(S O))) q r });
  (* three unknowns *)
  printf "\n What adds what equals to what ? (Give %d answers) \n\n" ans_no;
  ocrun3 ~n:ans_no (fun a b c -> ocanren { add a b c });;


printf "\n###### test div ######\n\n";;

let _ =
  let p17 = groundi_of_int 17 in
  (* checking *)
  printf "\n Checking \n\n";
  ocrun1 (fun q -> ocanren { div p17 (S(S(S O))) (S(S(S(S(S O))))) (S(S O))});
  ocrun1 (fun q -> ocanren { div (S O) p17 O (S O) });
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run1 (fun q -> ocanren { div (S O) O O (S O) | div (S O) (S(S O)) (S O) O }) ;
  (* one unknown *)
  printf "\n 17 divided by 5 equals 3 with remainder what ? \n\n";
  ocrun1 (fun q -> ocanren { div p17 (S(S(S(S(S O))))) (S(S(S O))) q });
  printf "\n 17 divided by 5 equals what with remainder 2 ?  \n\n";
  ocrun1 (fun q -> ocanren { div p17 (S(S(S(S(S O))))) q (S(S(O))) });
  printf "\n 17 divided by what equals 3 with remainder 2? \n\n";
  ocrun1 (fun q -> ocanren { div p17 q (S(S(S O))) (S(S O)) });
  printf "\n What divided by 5 equals 3 with remainder 2? \n\n";
  ocrun1 (fun q -> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) (S(S O)) });
  (* use div for multiplication *)
  printf "\n What divided by 5 equals 3 with remainder 0 ? \n\n";
  ocrun1 (fun q -> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) O });
  (* two unknowns *)  
  let ans_no = 10 in
  printf "\n What divided by what equals 3 with remainder 2 ? (Give %d answers) \n\n" ans_no;
  ocrun2 ~n:ans_no (fun q r-> ocanren { div q r (S(S(S O))) (S(S O)) });
  printf "\n What divided by 5 equals what with remainder 2 ? (Give %d answers)\n\n" ans_no;
  ocrun2 ~n:ans_no (fun q r-> ocanren { div q (S(S(S(S(S O))))) r (S(S O)) });
  printf "\n What divided by 5 equals 3 with remainder what ? (Give all answers)\n\n";
  ocrun2 (fun q r-> ocanren { div q (S(S(S(S(S O))))) (S(S(S O))) r });
  printf "\n 17 divided by what equals what with remainder 2 ? (Give all answers) \n\n";
  ocrun2 (fun q r-> ocanren { div p17 q r (S(S O)) });
  printf "\n 17 divided by what equals 3 with remainder what ? (Give all answers)\n\n";
  ocrun2 (fun q r-> ocanren { div p17 q (S(S(S O))) r });
  printf "\n 17 divided by 5 equals what with remainder what ? \n\n";
  ocrun2 (fun q r-> ocanren { div p17 (S(S(S(S(S O))))) q  r });
  (* three unknowns *)
  printf "\n 17 divided by what equals what with remainder what? (Give all answers)\n\n" ;
  ocrun3 (fun a b c -> ocanren { div p17 a b c });
  let ans_no = 60 in
  printf "\n What divided by 5 equals what with remainder what? (Give %d answers)\n\n" ans_no;
  ocrun3 ~n:ans_no (fun a b c -> ocanren { div a (S(S(S(S(S O))))) b c });
  printf "\n What divided by what equals 3 with remainder what? (Give %d answers)\n\n" ans_no;
  ocrun3 ~n:ans_no (fun a b c -> ocanren { div a b (S(S(S O))) c });
  printf "\n What divided by what equals what with remainder 2? (Give %d answers)\n\n" ans_no;
  ocrun3 ~n:ans_no (fun a b c -> ocanren { div a b c (S(S O)) });
  (* four unknowns *)
  printf "\n What divided by what equals what with remainder what? \n\n";
  ocrun4 ~n:ans_no (fun a b c d -> ocanren { div a b c d });;
  
  
printf "\n###### test gcd ######\n\n";;

let _ =
  let p7  = groundi_of_int 7
  and p14 = groundi_of_int 14
  and p21 = groundi_of_int 21 in
  (* checking *)
  printf "\n Checking \n\n";
  ocrun1 (fun q -> ocanren { gcd p21 p14 p7 & gcd p14 p7 p7 });
  printf "%d answer(s) found.\n" @@ List.length @@ take @@
    run1  (fun q -> ocanren { gcd p21 p7 p14 | add p7 p7 (S O) });
  (* one unknown *)
  printf "\n The gcd of 21 and 14 is what ? \n\n";
  ocrun1 (fun q -> ocanren { gcd p21 p14 q });
  printf "\n  The gcd of 21 and what is 7 ? \n\n";
  ocrun1 (fun q -> ocanren { gcd p21 q p7 });
  let ans_no = 60 in
  printf "\n The gcd of what and 14 is 7 ? (give %d answers) \n\n" ans_no;
  ocrun1 ~n:ans_no (fun q -> ocanren { gcd q p14 p7 });
  (* two unknowns *)
  printf "\n The gcd of what and what is 7 ?  (give %d answers) \n\n" ans_no;
  ocrun2 ~n:ans_no (fun q r -> ocanren { gcd' q r p7 })
  (*let ans_no = 10 in
  printf "\n What adds 4 equals to what ? (Give %d answers) \n\n" ans_no;
  ocrun2 ~n:ans_no (fun q r -> ocanren { add q  (S(S(S(S O)))) r });
  printf "\n 3 adds what equals to what ? \n\n";
  ocrun2 (fun q r -> ocanren { add (S(S(S O))) q r });
  (* three unknowns *)
  printf "\n What adds what equals to what ? (Give %d answers) \n\n" ans_no;
  ocrun3 ~n:ans_no (fun a b c -> ocanren { add a b c })*);;
