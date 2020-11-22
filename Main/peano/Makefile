TOPFILE = peano
SOURCES = peano.ml test.ml
OCAMLC = ocamlfind c
OCAMLOPT = ocamlfind opt
OCAMLDEP = ocamlfind dep
OUTB = $(TOPFILE).byte
OUTO = $(TOPFILE).opt
CAMLP5 = -syntax camlp5o -package ocanren.syntax,GT.syntax.all 
PXFLAGS = $(CAMLP5)
# add flag -i to BFLAGS to show in the terminal the type signature of the program
# add flag -dsource to BFLAG to dispaly in the terminal the source code after syntax expansion
BFLAGS = -rectypes -g 
OFLAGS = $(BFLAGS)
CLEAN = $(wildcard *.cmi *.cmo *.cmx *.annot *.o *.opt *.byte *~ *depend)

.PHONY : all clean

all:.depend $(OUTO)

.depend: $(SOURCES)
	$(OCAMLDEP) $(PXFLAGS) *.ml > .depend

$(OUTO): $(SOURCES:.ml=.cmx)
	$(OCAMLOPT) -o $(OUTO) $(OFLAGS) $(LIBS:.cma=.cmxa) -linkpkg -package GT,ocanren $(SOURCES:.ml=.cmx) 

$(OUTB): $(SOURCES:.ml=.cmo)
	$(OCAMLC) -o $(OUTB) $(BFLAGS) $(LIBS) -linkpkg -package GT,ocanren $(SOURCES:.ml=.cmo) 

clean:
	rm -Rf $(CLEAN)

-include .depend
# generic rules

###############
%.cmi: %.mli
	$(OCAMLC) -c $(BFLAGS) $(PXFLAGS) $<

# Note: cmi <- mli should go first
%.cmi: %.ml
	$(OCAMLC) -c $(BFLAGS) $(PXFLAGS) $<

%.cmo: %.ml
	$(OCAMLC) -c $(BFLAGS) $(PXFLAGS) $<

%.o: %.ml
	$(OCAMLOPT) -c $(OFLAGS) $(STATIC) $(PXFLAGS) $<

%.cmx: %.ml
	$(OCAMLOPT) -c $(OFLAGS) $(STATIC) $(PXFLAGS) $<
