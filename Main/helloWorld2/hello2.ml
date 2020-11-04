open OCanren;;


@type 'a logic' = 'a logic with show;;

module String = struct
  @type t = GT.string with show;;        
  @type ground = t with show;;
  @type logic = t logic' with show;;
  type groundi = (ground, logic) injected;;
end;;


let str : String.groundi = !!("hello world!\n");;

let _ =
  List.iter print_string @@
    Stream.take ~n:1 @@
      run q (fun q -> ocanren { q == str }) project;;



