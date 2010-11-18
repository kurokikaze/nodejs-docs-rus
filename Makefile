docs_dirs = $(wildcard v*.*.*)

# http://www.gnu.org/software/make/manual/make.html#Setting
TMP := $(shell mktemp --tmpdir -d temp.XXXXXXXXXX)
DESC := $(shell git describe --always)

all:
	cp ./index.htm ./index.html
	@for d in $(docs_dirs); do \
		(cd $$d; make); \
	done; \

clean:
	rm -f ./index.html
	@for d in $(docs_dirs); do \
		(cd $$d; make clean); \
	done; \

gh-pages:
	mv ./index.html $(TMP)
	cp -r ./assets $(TMP)
	@for d in $(docs_dirs); do \
		mkdir $(TMP)/$$d; \
		mv ./$$d/*.html $(TMP)/$$d; \
		cp -r ./$$d/assets $(TMP)/$$d; \
	done; \
	git checkout gh-pages
	cp -r $(TMP)/* ./
	git add ./*
	git ci -m "Update from master/$(DESC)"
	git checkout master

pages: all gh-pages clean

.PHONY: all clean gh-pages pages
