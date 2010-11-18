docs_dirs = $(wildcard ./v*.*.*)

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

.PHONY: all clean
