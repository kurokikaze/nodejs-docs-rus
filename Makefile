docs_dirs = $(wildcard ./v*.*.*)

all:
	@for d in $(docs_dirs); do \
		(cd $$d; make); \
	done; \

clean:
	@for d in $(docs_dirs); do \
		(cd $$d; make clean); \
	done; \

.PHONY: all clean
