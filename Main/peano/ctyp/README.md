# A Note on Extending the `ctyp` Grammar Entry

The definition of types at the logic level can be conceptually simplified  by extending the
standard OCaml `ctyp` entry that is for the syntactic category of
[type expressons](https://ocaml.org/releases/4.11/htmlman/types.html).

The effect of the extension is that we define the type constructor
`llist` for logic list types by:
```ocaml
@type 'a llist = ocanren { ('a, !('a llist)) alist } with show    (* TyEq *)
```
where `alist` is the type constructor for the abstract list type.

The above logic type definition is conceptually closer to the ground level list type definition:
```ocaml
@type 'a glist = ('a, 'a glist) alist  with show
```
than its alternative:
```ocaml
@type 'a llist = ('a, 'a llist) alist OCanren.logic with show
```

We collect the definitions for `alist`, `glist` and `llist` in [`tt.ml`](./tt.ml) and generate
its interface [`tt.mli`](./tt.mli) using the `-i` option in the [Makefile](./Makefile#L12)
together with the command `make > tt.mli` (followded by some minor editing).


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
      | "("; t = SELF; ")" -> <:ctyp< $t$ >> ] ]
  ;
```
The `ctyp` entry from the OCanren syntax entension kit
[pa_ocanren.ml](../../../Installation/ocanren/camlp5/pa_ocanren.ml) is reproduced as follows:
```ocaml
 ctyp: [
      [ "ocanren"; "{"; t=ctyp; "}" -> decorate_type t ]
    | "simple" [ "!"; "("; t=ctyp; ")" -> <:ctyp< ocanren $t$ >> ]];
```