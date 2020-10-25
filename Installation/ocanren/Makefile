MKDIR ?= mkdir -vp
CP    ?= cp

.NOTPARALLEL :

OB=ocamlbuild -use-ocamlfind -classic-display
ifdef OBV
OB += -verbose 6
endif

SRC=src,src/core,src/std

CMA_TARGETS=src/OCanren.cma
BYTE_TARGETS=$(CMA_TARGETS) 
NATIVE_TARGETS= $(CMA_TARGETS:.cma=.cmxa) 

.PHONY: all celan clean clean_tests cleanppx install uninstall \
  tests test regression promote_all \
	ppx ppxnew doc \
	only-toplevel toplevel lib tester bundle plugin samples

.DEFAULT_GOAL: all

all: bundle 
bundle: lib plugin
lib:
	$(OB) -r -Is $(SRC) $(BYTE_TARGETS) $(NATIVE_TARGETS)

plugin:
	$(OB) camlp5/pa_ocanren.cmo

clean: 
	$(RM) -r _build *.log  *.native *.byte *.docdir

######################## Installation related stuff ##########################
INSTALL_TARGETS=META \
	$(wildcard _build/regression/tester.cm[iotx]) \
	$(wildcard _build/regression/tester.o) \
	$(wildcard _build/src/*.cm[ti]) \
	$(wildcard _build/src/core/*.cm[ti]) \
	$(wildcard _build/src/std/*.cm[ti]) \
	_build/src/OCanren.cmx \
	_build/src/OCanren.cma \
	_build/src/OCanren.cmxa \
	$(wildcard _build/ppx/pp_ocanren_all.native) \
	$(wildcard _build/ppx/pp_fresh.native) \
	$(wildcard _build/ppx/ppx_fresh.a) \
	$(wildcard _build/ppx/ppx_fresh.cma) \
	$(wildcard _build/ppx/ppx_fresh.cmxa) \
	$(wildcard _build/ppx/pp_repr.native) \
	$(wildcard _build/ppx/ppx_repr.a) \
	$(wildcard _build/ppx/ppx_repr.cma) \
	$(wildcard _build/ppx/ppx_repr.cmxa) \
	$(wildcard _build/ppx/pp_ocanren_all.cmxa) \
	$(wildcard _build/ppx/pp_ocanren_all.cmxs) \
	$(wildcard _build/ppx/pp_ocanren_all.native) \
	$(wildcard _build/src/OCanren.[oa]) \
	$(wildcard _build/ppxnew/pp_distrib.native) \
	$(wildcard _build/ppxnew/ppx_distrib.a) \
	$(wildcard _build/ppxnew/ppx_distrib.cm[tiaox]) \
	$(wildcard _build/ppxnew/ppx_distrib.cmxa) \
	$(wildcard _build/camlp5/pa_ocanren.cm[oi]) \

BUNDLEDIR=_build/bundle/ocanren

define MAKE_BUNDLE_RULE
$(BUNDLEDIR)/$(notdir $(1)): $(1)
	@cp $(1) $(BUNDLEDIR)
MAKE_BUNDLE_TARGETS += $(BUNDLEDIR)/$(notdir $(1))
endef
$(foreach i,$(INSTALL_TARGETS),$(eval $(call MAKE_BUNDLE_RULE,$(i)) ) )

rmbundledir:
	@$(RM) -r $(BUNDLEDIR)

$(BUNDLEDIR):
	@$(MKDIR) $@

bundle: rmbundledir $(BUNDLEDIR)
	$(MAKE) really_make_bundle

really_make_bundle: $(MAKE_BUNDLE_TARGETS)

install: bundle
	ocamlfind install ocanren $(BUNDLEDIR)/*

uninstall:
	ocamlfind remove ocanren

doc: all bundle compile_tests
	$(OB) OCanren.docdir/index.html -Is src
