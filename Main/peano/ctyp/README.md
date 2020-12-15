# A Note on Extending the `ctyp` Grammar Entry

The definition of types at the logic level can be conceptually simplified  by extending the
standard OCaml `ctyp` entry that is for the syntactic category of
[type expressons](https://ocaml.org/releases/4.11/htmlman/types.html).

The effect of the extension is that we define the type constructor
`llist` for logic list types by:
```ocaml
@type 'a llist = ocanren { ('a, !('a llist)) alist } with show
```
where `alist` is the type constructor for the abstract list type.

The above logic type definition is closer to the ground level list type definition:
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