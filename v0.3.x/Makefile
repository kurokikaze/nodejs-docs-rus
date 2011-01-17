apidoc_markdown = $(wildcard ./*.markdown)
apidoc_html = $(apidoc_markdown:.markdown=.html)

all: $(apidoc_html)

%.html: %.markdown ./doctool/doctool.js ./doctool/template.html
	node ./doctool/doctool.js ./doctool/template.html $< > $@

all.html: $(apidoc_markdown) ./doctool/doctool.js ./doctool/template.html
	node ./doctool/doctool.js ./doctool/template.html all.markdown > all.html

clean:
	rm -f ./*.html

.PHONY: all clean
