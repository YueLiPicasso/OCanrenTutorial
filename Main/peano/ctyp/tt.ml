@type ('a, 'b) alist = Nil | Cons of 'a * 'b with show;;
@type 'a       glist = ('a, 'a glist) alist  with show;;
@type 'a       llist = ocanren { ('a, 'a !(llist)) alist } with show;;

(* parsing RHS of 'a llist with the entry [ctyp]:

<:ctyp< alist 'a (ocanren (llist 'a)) >>

Pass this to decorate_type:
<:ctyp< OCanren.logic ((OCanren.logic (OCanren.logic alist) 'a)  (llist 'a)) >>
 *)


@type ('a, 'b) atree = Leaf of 'b | Node of 'b * 'a * 'a with show;;
@type 'b       gtree = ('b gtree, 'b) atree with show;;
@type 'b       ltree = ocanren { ('b !(ltree), 'b) atree } with show;;

                                                                                                                    
(* parsing RHS of 'b ltree with the entry [ctyp]:

<:ctyp < alist (ocanren (ltree 'b)) 'b >>

Pass this to decorate_type:
<:ctyp< OCanren.logic (alist (ocanren (ltree 'b)) 'b) >>
 *)
