@type ('a, 'b) alist = Nil | Cons of 'a * 'b with show;;
@type 'a       glist = ('a, 'a glist) alist  with show;;
@type 'a       llist = ocanren { ('a, !('a llist)) alist } with show;;
