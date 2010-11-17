apidoc_markdown = $(wildcard ./*.markdown)
apidoc_html = $(apidoc_markdown:.markdown=.html)

all: $(apidoc_html)

%.html: %.markdown
	node ./doctool/doctool.js ./doctool/template.html $< > $@

all.html: $(apidoc_markdown)
	node ./doctool/doctool.js ./doctool/template.html all.markdown > all.html

clean:
	rm -f ./*.html

