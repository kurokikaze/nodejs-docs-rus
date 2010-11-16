apidoc_markdown = $(wildcard ./*.markdown)
apidoc_html = $(apidoc_markdown:.markdown=.html)

all: $(apidoc_html)

%.html: %.markdown
	node ./doctool/doctool.js ./doctool/template.html $< > $@

clean:
	rm -f ./*.html

