We parse the [OCanren formulae parser](../../Installation/ocanren/camlp5/pa_ocanren.ml#L226) according to the [extensible grammar](https://camlp5.github.io/doc/htmlc/grammars.html#a:Syntax-of-the-EXTEND-statement) of camlp5.  

This is an _entry_:
```
ocanren_expr: [
    "top" RIGHTA [ l=SELF; "|"; r=SELF -> <:expr< OCanren.disj $l$ $r$ >> ] |
          RIGHTA [ l=SELF; "&"; r=SELF -> <:expr< OCanren.conj $l$ $r$ >> ] |
    [ "fresh"; vars=LIST1 LIDENT SEP ","; "in"; b=ocanren_expr LEVEL "top" ->
       List.fold_right
         (fun x b ->
            let p = <:patt< $lid:x$ >> in
            <:expr< OCanren.call_fresh ( fun $p$ -> $b$ ) >>
         )
         vars
         b                                        
    ] |
    "primary" [
        p=prefix; t=ocanren_term                      -> let p = <:expr< $lid:p$ >> in <:expr< $p$ $t$ >> 
      | l=ocanren_term; "==" ; r=ocanren_term         -> <:expr< OCanren.unify $l$ $r$ >>
      | l=ocanren_term; "=/="; r=ocanren_term         -> <:expr< OCanren.diseq $l$ $r$ >>
      | l=ocanren_term; op=operator; r=ocanren_term   -> let p = <:expr< $lid:op$ >> in
                                                         let a = <:expr< $p$ $l$ >> in
                                                         <:expr< $a$ $r$ >>
      | x=ocanren_term                                -> x
      | "{"; e=ocanren_expr; "}"                      -> e 
      | "||"; "("; es=LIST1 ocanren_expr SEP ";"; ")" -> <:expr< OCanren.conde $list_of_list es$ >> 
      | "&&"; "("; es=LIST1 ocanren_expr SEP ";"; ")" ->
         let op = <:expr< $lid:"?&"$ >> in
         let id = <:expr< OCanren . $op$ >> in
         <:expr< $id$ $list_of_list es$ >>  
    ]
  ];
```
The entry has the following _levels_:

Level 1.
```
 "top" RIGHTA [ l=SELF; "|"; r=SELF -> <:expr< OCanren.disj $l$ $r$ >> ]
```
Level 2.
```
 RIGHTA [ l=SELF; "&"; r=SELF -> <:expr< OCanren.conj $l$ $r$ >> ]
```

Level 3.
```
[ "fresh"; vars=LIST1 LIDENT SEP ","; "in"; b=ocanren_expr LEVEL "top" ->
       List.fold_right
         (fun x b ->
            let p = <:patt< $lid:x$ >> in
            <:expr< OCanren.call_fresh ( fun $p$ -> $b$ ) >>
         )
         vars
         b                                        
    ] 
```
Level 4.
```
"primary" [
        p=prefix; t=ocanren_term                      -> let p = <:expr< $lid:p$ >> in <:expr< $p$ $t$ >> 
      | l=ocanren_term; "==" ; r=ocanren_term         -> <:expr< OCanren.unify $l$ $r$ >>
      | l=ocanren_term; "=/="; r=ocanren_term         -> <:expr< OCanren.diseq $l$ $r$ >>
      | l=ocanren_term; op=operator; r=ocanren_term   -> let p = <:expr< $lid:op$ >> in
                                                         let a = <:expr< $p$ $l$ >> in
                                                         <:expr< $a$ $r$ >>
      | x=ocanren_term                                -> x
      | "{"; e=ocanren_expr; "}"                      -> e 
      | "||"; "("; es=LIST1 ocanren_expr SEP ";"; ")" -> <:expr< OCanren.conde $list_of_list es$ >> 
      | "&&"; "("; es=LIST1 ocanren_expr SEP ";"; ")" ->
         let op = <:expr< $lid:"?&"$ >> in
         let id = <:expr< OCanren . $op$ >> in
         <:expr< $id$ $list_of_list es$ >>  
    ]
```
Level 4 has the following _rules_:

Rule 4.1.
```
p=prefix; t=ocanren_term                      -> let p = <:expr< $lid:p$ >> in <:expr< $p$ $t$ >> 
```

Rule 4.2.
```
l=ocanren_term; "==" ; r=ocanren_term         -> <:expr< OCanren.unify $l$ $r$ >>
```

Rule 4.3.
```
l=ocanren_term; "=/="; r=ocanren_term         -> <:expr< OCanren.diseq $l$ $r$ >>
```

Rule 4.4.
```
l=ocanren_term; op=operator; r=ocanren_term   -> let p = <:expr< $lid:op$ >> in
                                                         let a = <:expr< $p$ $l$ >> in
                                                         <:expr< $a$ $r$ >>
```

Rule 4.5.
```
x=ocanren_term                                -> x
```

Rule 4.6.
```
"{"; e=ocanren_expr; "}"                      -> e 
```

Rule 4.7.
```
"||"; "("; es=LIST1 ocanren_expr SEP ";"; ")" -> <:expr< OCanren.conde $list_of_list es$ >>
```

Rule 4.8.
```
 "&&"; "("; es=LIST1 ocanren_expr SEP ";"; ")" ->
         let op = <:expr< $lid:"?&"$ >> in
         let id = <:expr< OCanren . $op$ >> in
         <:expr< $id$ $list_of_list es$ >>  
```