# A Note on Extending the `ctyp` Grammar Entry

The definition of types at the logic level can be conceptually simplified  by extending the
standard OCaml `ctyp` entry that is for the syntactic category of
[type expressons](https://ocaml.org/releases/4.11/htmlman/types.html).

The effect of the extension is that we can define the type constructor
`llist` for logic list types by:
```ocaml
@type 'a llist = ocanren { ('a, !('a llist)) alist } with show    (* TyEq *)
```
where `alist` is the type constructor for the abstract list type. 

The above logic type definition has the same structure as the ground level list type definition:
```ocaml
@type 'a glist = ('a, 'a glist) alist  with show
```
despite the syntactic elements: the  `ocanren{}` quotation and the `!()` antiquotation.

The  alternative definition is conceptually more delicate:
```ocaml
@type 'a llist = ('a, 'a llist) alist OCanren.logic with show    (* TyEq-a *)
```
We collect the definitions for `alist`, `glist` and `llist` in [`tt.ml`](./tt.ml) and generate
its interface [`tt.mli`](./tt.mli) using the `-i` option in the [Makefile](./Makefile#L10)
together with the command `make > tt` (followed by some minor editing such as renaming the file,
deleting some not needed output and adding extra spaces). We could [see](tt.mli#L65) in the interface that
`(* TyEq *)` is expanded into `(* TyEq-a *)`.


Let's analyze, as a worked example, how the right hand side of the
type equation `(* TyEq *)` is parsed by the extended `ctyp` entry. The
original `ctyp` entry from [`pa_o.ml`](../camlp5_src_ref/pa_o.ml) is copied below:
```ocaml
(* Core types *)
  ctyp:
    [ [ t1 = SELF; "as"; "'"; i = ident -> <:ctyp< $t1$ as '$i$ >> ]
    | "arrow" RIGHTA
      [ t1 = SELF; "->"; t2 = SELF -> <:ctyp< $t1$ -> $t2$ >> ]
    | "star"
      [ t = SELF; "*"; tl = LIST1 (ctyp LEVEL "apply") SEP "*" ->
          <:ctyp< ( $list:[t :: tl]$ ) >> ]
    | "apply"
      [ t1 = SELF; t2 = SELF -> <:ctyp< $t2$ $t1$ >> ]
    | "ctyp2"
      [ t1 = SELF; "."; t2 = SELF -> <:ctyp< $t1$ . $t2$ >>
      | t1 = SELF; "("; t2 = SELF; ")" -> <:ctyp< $t1$ $t2$ >> ]
    | "simple"
      [ "'"; i = V ident "" -> <:ctyp< '$_:i$ >>
      | "_" -> <:ctyp< _ >>
      | i = V LIDENT -> <:ctyp< $_lid:i$ >>
      | i = V UIDENT -> <:ctyp< $_uid:i$ >>
      | "("; "module"; mt = module_type; ")" -> <:ctyp< module $mt$ >>
      | "("; t = SELF; ","; tl = LIST1 ctyp SEP ","; ")";
        i = ctyp LEVEL "ctyp2" ->
          List.fold_left (fun c a -> <:ctyp< $c$ $a$ >>) i [t :: tl]
      | "("; t = SELF; ")" -> <:ctyp< $t$ >> ] ];
```
The `ctyp` entries from the OCanren syntax entension kit
[pa_ocanren.ml](../../../Installation/ocanren/camlp5/pa_ocanren.ml) is reproduced as follows:
```ocaml
ctyp:
  [ [ "ocanren"; "{"; t=ctyp; "}" -> decorate_type t ] ]
;
ctyp: LEVEL "simple"
  [ ["!"; "("; t=ctyp; ")" -> <:ctyp< ocanren $t$ >> ] ]
;
```
The result of the extension is as follows, and from now on when we say `ctyp` we mean
this version: 
```ocaml
 ctyp:
    [ [ t1 = SELF; "as"; "'"; i = ident -> <:ctyp< $t1$ as '$i$ >>
      | "ocanren"; "{"; t=ctyp; "}" -> decorate_type t ]
    | "arrow" RIGHTA
      [ t1 = SELF; "->"; t2 = SELF -> <:ctyp< $t1$ -> $t2$ >> ]
    | "star"
      [ t = SELF; "*"; tl = LIST1 (ctyp LEVEL "apply") SEP "*" ->
          <:ctyp< ( $list:[t :: tl]$ ) >> ]
    | "apply"
      [ t1 = SELF; t2 = SELF -> <:ctyp< $t2$ $t1$ >> ]
    | "ctyp2"
      [ t1 = SELF; "."; t2 = SELF -> <:ctyp< $t1$ . $t2$ >>
      | t1 = SELF; "("; t2 = SELF; ")" -> <:ctyp< $t1$ $t2$ >> ]
    | "simple"
      [ "'"; i = V ident "" -> <:ctyp< '$_:i$ >>
      | "_" -> <:ctyp< _ >>
      | i = V LIDENT -> <:ctyp< $_lid:i$ >>
      | i = V UIDENT -> <:ctyp< $_uid:i$ >>
      | "("; "module"; mt = module_type; ")" -> <:ctyp< module $mt$ >>
      | "("; t = SELF; ","; tl = LIST1 ctyp SEP ","; ")";
        i = ctyp LEVEL "ctyp2" ->
          List.fold_left (fun c a -> <:ctyp< $c$ $a$ >>) i [t :: tl]
      | "("; t = SELF; ")" -> <:ctyp< $t$ >> 
      | "!"; "("; t=ctyp; ")" -> <:ctyp< ocanren $t$ >> ] ];
```
The right hand side of  `(* TyEq *)` is parsed by `ctyp` and results in the AST
(written as a quotation):
```ocaml
<:ctyp< alist 'a (ocanren (llist 'a)) >>
```
This AST is then passed to the
[`decorate_type`](../../../Installation/ocanren/camlp5/pa_ocanren.ml#L152)
function and the result is:
```ocaml
<:ctyp< OCanren.logic (alist 'a (llist 'a))>>
```
which reminds us of the right hand side of `(* TyEq-a *)`.

## Exception

The existing parser cannot tackle the following definition:

```ocaml
@type ('a, 'b) atree = Leaf of 'b | Node of 'b * 'a * 'a with show;;
@type 'b       gtree = ('b gtree, 'b) atree with show;;
@type 'b       ltree = ocanren { (!('b ltree), 'b) atree } with show;;
```

The cause is the clause below from `decorate_type`:
```ocaml
let rec decorate_type ctyp = 
  (* ... *)
  | <:ctyp< $x$ $y$ >> -> let t = <:ctyp< $x$ $decorate_type y$ >> in <:ctyp< OCanren.logic $t$ >>
  (* ... *)
```
Observe that `ctyp` turns the type expression:
```ocaml
ocanren { (!('b ltree), 'b) atree } 
```
into:
```ocaml
<:ctyp< atree (ocanren (ltree 'b)) 'b >>
```
which is then passed to `decorate_type` where the above clause applies.
The recursive occurrence of the logic type constructor `ltree` is on the left
part of the application (bound to `x`) but it is not further processed to
remove the `ocanren` tag. 
