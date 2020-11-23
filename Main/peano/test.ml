open OCanren;;
open Peano;;

let take = fun ?n s -> OCanren.Stream.take ?n s;;

(* checking *)
let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run q (fun q -> ocanren { lt O (S O) & lt (S O) (S(S O)) }) (fun q -> q#reify reify)

let _ = Printf.printf "%d answer(s) found.\n" @@ List.length @@ take @@
          run q (fun q -> ocanren { lt (S O) O | lt (S(S O)) (S O) }) (fun q -> q#reify reify)

(* 0 is less than what? *)
let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run q (fun q -> ocanren { lt O q }) (fun q -> q#reify reify)

(* 1 is less than what? *)
let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run q (fun q -> ocanren { lt (S O) q }) (fun q -> q#reify reify)

(* what is less than 5? *)
let _ = List.iter (fun x -> print_endline @@ GT.show(logic) x) @@ take @@
          run q (fun q -> ocanren { lt q (S(S(S(S(S O))))) }) (fun q -> q#reify reify)
