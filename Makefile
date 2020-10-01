#ALL_DEBUG=debug
ALL_DEBUG=

all: allegro.cmxa allegro.cma

alleg-wrap.o: alleg-wrap.c
	ocamlc -c $<

dll_alleg_stubs.so: alleg-wrap.o
	ocamlmklib  -o  _alleg_stubs  $<  \
		 `allegro-config --libs $(ALL_DEBUG)`


allegro.cmi: allegro.mli
	ocamlc -c $<


allegro.cmo: allegro.ml allegro.cmi
	ocamlc -c $<

allegro.cmx: allegro.ml allegro.cmi
	ocamlopt -c $<

CUSTOM=-custom

allegro.cma:  allegro.cmo  dll_alleg_stubs.so
	@# IFS is a hack to insure that the word spliting don't split "-framework Cocoa"
	IFS=^ ; \
	ocamlc -a  $(CUSTOM)  -o $@  $<  \
	      -dllib dll_alleg_stubs.so  \
	      -cclib -l_alleg_stubs  \
	      `allegro-config --libs $(ALL_DEBUG) | sed    \
			-e 's/ /^/g' \
			-e 's/-framework^Cocoa/-cclib^-framework Cocoa/g' \
			-e 's/-l/-cclib^-l/g' \
			-e 's/-L/-ccopt^-L/g' \
			-e 's/-W/-cclib^-W/g'`


allegro.cmxa:  allegro.cmx  dll_alleg_stubs.so
	IFS=^ ; \
	ocamlopt -a  -o $@  $<  \
	      -cclib -l_alleg_stubs  \
	      `allegro-config --libs $(ALL_DEBUG) | sed    \
			-e 's/ /^/g' \
			-e 's/-framework^Cocoa/-cclib^-framework Cocoa/g' \
			-e 's/-l/-cclib^-l/g' \
			-e 's/-L/-ccopt^-L/g' \
			-e 's/-W/-cclib^-W/g'`

# api documentation
doc: allegro.mli
	if [ ! -d doc ]; then mkdir doc ; fi
	ocamldoc -html -colorize-code -d doc $<
	sleep 1; touch $<

# test
DEMO=examples/exhello.ml

demo: $(DEMO) allegro.cmxa
	ocamlopt -ccopt -L./  allegro.cmxa $< -o `basename $< .ml`.opt

test: $(DEMO) demo allegro.cmxa
	./`basename $< .ml`.opt


clean:
	rm -f *.[oa] *.so *.cm[ixoa] *.cmxa *~ doc/*.{html,css} *.opt


# install 

PREFIX = "`ocamlc -where`/allegro"

DIST_FILES=\
    allegro.a         \
    allegro.cmi       \
    allegro.cma       \
    allegro.cmxa      \
    lib_alleg_stubs.a

SO_DIST_FILES=\
    dll_alleg_stubs.so


install: $(DIST_FILES)  $(SO_DIST_FILES)
	if [ ! -d $(PREFIX) ]; then install -d $(PREFIX) ; fi

	install -m 0755  \
	        $(SO_DIST_FILES)  \
	        $(PREFIX)/

	install -m 0644        \
	        $(DIST_FILES)  \
	        $(PREFIX)/
# end of install

# tar-ball

VERSION=alpha
R_DIR=ocaml-allegro-$(VERSION)
TARBALL=$(R_DIR).tgz

release: $(TARBALL)

$(R_DIR): allegro.ml allegro.mli alleg-wrap.c META Makefile README.txt LICENSE.txt examples
	mkdir -p $(R_DIR)
	cp -f allegro.ml allegro.mli alleg-wrap.c META Makefile README.txt LICENSE.txt $(R_DIR)/
	(cd examples && make clean)
	cp -r examples $(R_DIR)/

$(TARBALL): $(R_DIR)
	tar cf $(R_DIR).tar $(R_DIR)
	gzip -9 $(R_DIR).tar
	mv $(R_DIR).tar.gz $@

#EOF
