bindir = /usr/bin
datadir = /usr/share
sysconfdir = /etc

txttargets = $(shell echo examples/*.txt)
fodttargets = $(patsubst %.txt, %.fodt, $(txttargets))

.PHONY: all examples install

all:
	@echo "Nothing to do."

install:
	install -Dp -m0644 odt.conf $(DESTDIR)$(sysconfdir)/asciidoc/odt.conf
	install -Dp -m0644 stylesheets/asciidoc.odt.styles $(DESTDIR)$(sysconfdir)/asciidoc/stylesheets/asciidoc.odt.styles
	install -Dp -m0644 themes/cv/cv.odt.styles $(DESTDIR)$(sysconfdir)/asciidoc/themes/cv/cv.odt.styles
	install -Dp -m0755 filters/line_break.py $(DESTDIR)$(sysconfdir)/asciidoc/filters/line_break.py
	install -Dp -m0755 filters/code/code-filter.py $(DESTDIR)$(sysconfdir)/asciidoc/filters/code/code-filter.py
	install -Dp -m0644 filters/source/source-highlight-filter.conf $(DESTDIR)/asciidoc/filters/source/source-highlight-filter.conf
	echo "Please add \"odt = odt.outlang\" to $(datadir)/source-highlight/outlang.map"
	install -Dp -m0644 filters/source/odt.outlang $(DESTDIR)$(datadir)/source-highlight/odt.outlang
	install -Dp -m0755 packaged/a2x.py $(DESTDIR)$(bindir)/a2x.py
	install -Dp -m0644 packaged/a2x.conf $(DESTDIR)$(sysconfdir)/asciidoc/backends/odt/a2x.conf

examples: odt.conf $(fodttargets)
	asciidoc -b odt -a newline=\\n -a iconsdir=$(datadir)/asciidoc/images/icons -o examples/README.fodt README.asciidoc
	-xmllint --noout --relaxng xmllint/OpenDocument-v1.2-cs01-schema.rng examples/README.fodt
	asciidoc -b odt -a theme=cv -a newline=\\n examples/curriculum-vitae-dag-wieers.txt
	-xmllint --noout --relaxng xmllint/OpenDocument-v1.2-cs01-schema.rng examples/curriculum-vitae-dag-wieers.fodt

%.fodt: %.txt
	asciidoc -b xhtml11 -a iconsdir=$(datadir)/asciidoc/images/icons -o $(patsubst %.fodt, %.html, $@) $<
	asciidoc -b odt -a newline=\\n -a iconsdir=$(datadir)/asciidoc/images/icons -o $@ $<
	-xmllint --noout --relaxng xmllint/OpenDocument-v1.2-cs01-schema.rng $@

test: examples

clean:
	rm -f examples/*.fodt examples/*.html
