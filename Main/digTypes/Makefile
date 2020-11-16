SOURCES = digTypes.ml
OCAMLC = ocamlfind c
OCAMLOPT = ocamlfind opt
OCAMLDEP = ocamlfind dep
# add flag -i to BFLAGS to show in the terminal the type signature of the program
BFLAGS = -rectypes 
OFLAGS = $(BFLAGS)
CLEAN = $(wildcard *.cmi *.cmo *.cmx *.annot *.o *.opt *~ .depend)

.PHONY : all clean

all:.depend $(SOURCES:.ml=.cmx)

.depend: $(SOURCES)
	$(OCAMLDEP) $(PXFLAGS) *.ml > .depend

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

%.o: %.ml
	$(OCAMLOPT) -c $(OFLAGS)  $<

%.cmx: %.ml
	$(OCAMLOPT) -c $(OFLAGS)  $<
