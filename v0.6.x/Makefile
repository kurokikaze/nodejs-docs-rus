apidoc_markdown = $(wildcard ./*.markdown)
apidoc_html = $(apidoc_markdown:.markdown=.html) all.html
apidoc_json = $(apidoc_markdown:.markdown=.json)

all: $(apidoc_html) $(apidoc_json)

%.html: %.markdown ./doctool/generate.js ./doctool/template.html
	node ./doctool/generate.js --format=html --template=./doctool/template.html $< > $@

%.json: %.markdown ./doctool/generate.js ./doctool/template.html
	node ./doctool/generate.js --format=json $< > $@

clean:
	rm -f ./*.html

.PHONY: all clean
