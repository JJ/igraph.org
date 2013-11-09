
all: nothing

HTML= index.html getstarted.html news.html \
      _layouts/default.html _layouts/newstemp.html _layouts/manual.html

CSS= css/affix.css css/manual.css css/other.css fonts/fonts.css

RMAN:= $(wildcard ../interfaces/R/igraph/man/*)

TMP:=$(shell mktemp -d /tmp/.XXXXX)

../doc/jekyll/stamp: ../doc/html/stamp
	cd ../doc && make jekyll

doc/c/stamp: ../doc/jekyll/stamp
	rm -rf doc/c
	mkdir -p doc
	cp -r ../doc/jekyll doc/c

../doc/igraph-docs.pdf: ../doc/igraph-docs.xml
	cd ../doc && make igraph-docs.pdf

doc/c/igraph-docs.pdf: ../doc/igraph-docs.pdf
	mkdir -p doc/c
	cp ../doc/igraph-docs.pdf doc/c/

../doc/igraph.info: ../doc/igraph-docs.xml
	cd ../doc && make igraph.info

doc/c/igraph.info: ../doc/igraph.info
	mkdir -p doc/c
	cp ../doc/igraph.info doc/c/

doc/r/stamp: $(RMAN)
	cd ../interfaces/R && make && \
	R CMD INSTALL --html --no-R --no-configure --no-inst \
	  --no-libs --no-exec --no-test-load -l $(TMP) igraph
	rm -rf doc/r
	mkdir -p doc/r
	../tools/rhtml.sh $(TMP)/igraph/html doc/r
	ln -s 00Index.html doc/r/index.html
	touch doc/r/stamp

doc/r/igraph.pdf: $(RMAN)
	mkdir -p doc/r
	cd ../interfaces/R/ && make
	R CMD Rd2pdf --no-preview --force -o doc/r/igraph.pdf \
	  ../interfaces/R/igraph

stamp: $(HTML) $(CSS) doc/c/stamp doc/r/stamp doc/r/igraph.pdf \
               doc/c/igraph.info doc/c/igraph-docs.pdf
	../tools/getversion.sh > _includes/igraph-version
	../interfaces/R/tools/convertversion.sh > _includes/igraph-rversion
	jekyll build
	touch stamp

deploy: stamp
	rsync -avz --delete _site/ igraph.org:www/

.PHONY: all deploy

