open OCanren;;

@type weekdays = Monday | Tuesday | Wednesday | Thursday | Friday with show;;

module Inj = struct
  let monday    = fun () -> !!(Monday)
  and tuesday   = fun () -> !!(Tuesday)
  and wednesday = fun () -> !!(Wednesday)
  and thursday  = fun () -> !!(Thursday)
  and friday    = fun () -> !!(Friday);;
end;;

open Inj;;

let next = fun d1 d2 ->
  ocanren{
      d1 == Monday & d2 == Tuesday
    | d1 == Tuesday & d2 == Wednesday
    | d1 == Wednesday & d2 == Thursday
    | d1 == Thursday & d2 == Friday
    | d1 == Friday & d2 == Monday 
    };;

@type wdpairs = weekdays * weekdays with show;;

let _ =
  List.iter (fun x -> print_string (GT.show(wdpairs) x ^ "\n")) @@ 
    Stream.take @@
      run qr (fun q r ->  next q r) (fun q r -> project q, project r);;
