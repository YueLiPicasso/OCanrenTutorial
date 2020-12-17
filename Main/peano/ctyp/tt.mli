type ('a, 'b) alist = Nil | Cons of 'a * 'b

class virtual ['ia, 'a, 'sa, 'ib, 'b, 'sb, 'inh, 'extra, 'syn] alist_t :
  object
    method virtual c_Cons : 'inh -> 'extra -> 'a -> 'b -> 'syn
    method virtual c_Nil : 'inh -> 'extra -> 'syn
  end
  
val gcata_alist :
  ('a, 'b, 'c, 'd, 'e, 'f, 'g, ('b, 'e) alist, 'h) #alist_t ->
  'g -> ('b, 'e) alist -> 'h
  
class ['a, 'b, 'c] show_alist_t :
  (unit -> 'a -> string) ->
  (unit -> 'b -> string) ->
  'd ->
  object
    constraint 'c = ('a, 'b) alist
    method c_Cons : unit -> 'c -> 'a -> 'b -> string
    method c_Nil : unit -> 'c -> string
  end
  
val alist :
  (('a, 'b, 'c, 'd, 'e, 'f, 'g, ('b, 'e) alist, 'h) #alist_t ->
   'g -> ('b, 'e) alist -> 'h,
   < show : ('i -> string) -> ('j -> string) -> ('i, 'j) alist -> string >,
   (('k -> ('l, 'm) alist -> 'n) ->
    ('o, 'l, 'p, 'q, 'm, 'r, 'k, ('l, 'm) alist, 'n) #alist_t) ->
   'k -> ('l, 'm) alist -> 'n)
  GT.t
  
val show_alist : ('a -> string) -> ('b -> string) -> ('a, 'b) alist -> string

type 'a glist = ('a, 'a glist) alist

class virtual ['ia, 'a, 'sa, 'inh, 'extra, 'syn] glist_t :
  object
    method virtual c_Cons : 'inh -> 'extra -> 'a -> 'a glist -> 'syn
    method virtual c_Nil : 'inh -> 'extra -> 'syn
  end
  
val gcata_glist :
  ('a, 'b, 'c, 'd, 'e, 'f, 'g, ('b, 'e) alist, 'h) #alist_t ->
  'g -> ('b, 'e) alist -> 'h
class ['a, 'b] show_glist_t :
  (unit -> 'a -> string) ->
  (unit -> 'a glist -> string) ->
  object
    constraint 'b = 'a glist
    method c_Cons : unit -> 'b -> 'a -> 'a glist -> string
    method c_Nil : unit -> 'b -> string
  end
  
val glist :
  (('a, 'b, 'c, 'd, 'e, 'f, 'g, ('b, 'e) alist, 'h) #alist_t ->
   'g -> ('b, 'e) alist -> 'h,
   < show : ('i -> string) -> (('i, 'j) alist as 'j) -> string >,
   (('k -> ('l, 'm) alist -> 'n) ->
    ('o, 'l, 'p, 'q, 'm, 'r, 'k, ('l, 'm) alist, 'n) #alist_t) ->
   'k -> ('l, 'm) alist -> 'n)
  GT.t
  
val show_glist : ('a -> string) -> (('a, 'b) alist as 'b) -> string

type 'a llist = ('a, 'a llist) alist OCanren.logic

class virtual ['ia, 'a, 'sa, 'inh, 'extra, 'syn] llist_t :
  object
    method virtual c_Value : 'inh -> 'extra -> ('a, 'a llist) alist -> 'syn
    method virtual c_Var :
      'inh ->
      'extra -> GT.int -> ('a, 'a llist) alist OCanren.logic GT.list -> 'syn
  end
  
val gcata_llist :
  < c_Value : 'a -> 'b OCanren.logic -> 'b -> 'c;
    c_Var : 'a ->
            'b OCanren.logic -> GT.int -> 'b OCanren.logic GT.list -> 'c;
    .. > ->
  'a -> 'b OCanren.logic -> 'c
  
class ['a, 'b] show_llist_t :
  (unit -> 'a -> string) ->
  (unit -> ('a, 'a llist) alist OCanren.logic -> string) ->
  object
    constraint 'b = 'a llist
    method c_Value :
      unit ->
      ('a, 'a llist) alist OCanren.logic -> ('a, 'a llist) alist -> string
    method c_Var :
      unit ->
      ('a, 'a llist) alist OCanren.logic ->
      GT.int -> ('a, 'a llist) alist OCanren.logic GT.list -> string
  end
  
val llist :
  (< c_Value : 'a -> 'b OCanren.logic -> 'b -> 'c;
     c_Var : 'a ->
             'b OCanren.logic -> GT.int -> 'b OCanren.logic GT.list -> 'c;
     .. > ->
   'a -> 'b OCanren.logic -> 'c,
   < show : ('d -> string) -> (('d, 'e) alist OCanren.logic as 'e) -> string >,
   (('f -> 'g OCanren.logic -> 'h) ->
    < c_Value : 'f -> 'g OCanren.logic -> 'g -> 'h;
      c_Var : 'f ->
              'g OCanren.logic -> GT.int -> 'g OCanren.logic GT.list -> 'h;
      .. >) ->
   'f -> 'g OCanren.logic -> 'h)
  GT.t
  
val show_llist :
  ('a -> string) -> (('a, 'b) alist OCanren.logic as 'b) -> string
