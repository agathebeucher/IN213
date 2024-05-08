OCAMLC=ocamlc
OCAMLYACC=ocamlyacc
OCAMLLEX=ocamllex

all: main son

main: musicast.cmo musicparser.cmo musiclexer.cmo main.cmo
	$(OCAMLC) -o main $^

main.cmo: main.ml musicast.cmo musicparser.cmo musiclexer.cmo
	$(OCAMLC) -c $<

musicast.cmo: musicast.ml
	$(OCAMLC) -c $<

musicparser.cmo: musicparser.ml musicparser.cmi musicast.cmo
	$(OCAMLC) -c $<

musicparser.cmi: musicparser.mli
	$(OCAMLC) -c $<

musicparser.ml musicparser.mli: musicparser.mly
	$(OCAMLYACC) $<

musiclexer.cmo: musiclexer.ml musicparser.cmo
	$(OCAMLC) -c $<

musiclexer.ml: musiclexer.mll
	$(OCAMLLEX) $<

son: musicast.cmo musicparser.cmo musiclexer.cmo sonast.cmo son.cmo
	$(OCAMLC) -I +unix unix.cma -o $@ $^

sonast.cmo: sonast.ml
	$(OCAMLC) -c $<

son.cmo: son.ml
	$(OCAMLC) -c $<	

clean:
	rm -f *.cmo *.cmi musicparser.ml musicparser.mli musiclexer.ml main son
cleanall: clean
	rm -f test.xml test.pdf