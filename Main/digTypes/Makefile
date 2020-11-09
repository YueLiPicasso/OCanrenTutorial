TOPFILE = types
SOURCES = digTypes.ml
OCAMLC = ocamlfind c
OCAMLOPT = ocamlfind opt
OCAMLDEP = ocamlfind dep
OUTO = $(TOPFILE).opt
# add flag -i to BFLAGS to show in the terminal the type signature of the program
BFLAGS = -rectypes 
OFLAGS = $(BFLAGS)
CLEAN = $(wildcard *.cmi *.cmo *.cmx *.annot *.o *.opt *~ .depend)

.PHONY : all clean

all:.depend $(OUTO)

.depend: $(SOURCES)
	$(OCAMLDEP) $(PXFLAGS) *.ml > .depend

$(OUTO): $(SOURCES:.ml=.cmx)
	$(OCAMLOPT) -o $(OUTO) $(OFLAGS) $(LIBS:.cma=.cmxa) $(SOURCES:.ml=.cmx) 

clean:
	rm -Rf $(CLEAN)

-include .depend
# generic rules

###############
%.cmi: %.mli
	$(OCAMLC) -c $(BFLAGS) $<

# Note: cmi <- mli should go first
%.cmi: %.ml
	$(OCAMLC) -c $(BFLAGS)  $<

%.cmo: %.ml
	$(OCAMLC) -c $(BFLAGS)  $<

%.o: %.ml
	$(OCAMLOPT) -c $(OFLAGS)  $<

%.cmx: %.ml
	$(OCAMLOPT) -c $(OFLAGS)  $<
