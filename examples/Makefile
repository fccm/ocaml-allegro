MLALLEG=$(shell if test -d /usr/lib/ocaml/allegro ; then echo "+allegro"; else echo "../"; fi)

all:
	for f in *.ml; do \
	    CMD="ocamlopt -I $(MLALLEG) allegro.cmxa $$f -o `basename $$f .ml`.opt"; \
	    echo $$CMD; \
	    $$CMD; \
	done

clean:
	rm -f *.cm[ioxa] *.o *.opt *~

