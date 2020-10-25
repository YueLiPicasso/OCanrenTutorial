open OCanren;;

let str = !!("hello world!\n");;

let _ =
  List.iter print_string @@
    Stream.take ~n:1 @@
      run q (fun q -> ocanren { q == str }) project;;
