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

let _ = Printf.printf "%d answer(s) found.\n" @@ List.length @@ take @@
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

