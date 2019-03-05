WIKIDIR=wiki
BLOGDIR=blog-contents
OTHERDIR=other-pages
PROJDIR=projects
OUTDIR=out
TMPDIR=tmp

WSOURCES = $(wildcard $(WIKIDIR)/*.md)
BSOURCES = $(wildcard $(BLOGDIR)/*.md)
PSOURCES = $(wildcard $(PROJDIR)/*.md)
OSOURCES = $(wildcard $(OTHERDIR)/*.md)

WHTML = $(patsubst %.md,$(WIKIDIR)/%.html,$(WSOURCES))
BHTML = $(patsubst %.md,$(BLOGDIR)/%.html,$(BSOURCES))
PHTML = $(patsubst %.md,$(PROJDIR)/%.html,$(PSOURCES))
OHTML = about.html contact.html index.html projects.html

define sequence =
	# create temporary markdown file
	$(eval FILENAME=$(basename $(notdir $@)))
	$(eval TMPFILE=$(addsuffix .md,$(TMPDIR)/$(FILENAME)))
	touch $(TMPFILE)
	cat html-parts/head.html >> $(TMPFILE)
	echo \<title\>$(FILENAME)\<\/title\> >> $(TMPFILE)
	echo \<\/head\> >> $(TMPFILE)
	echo \<body\> >> $(TMPFILE)
	cat html-parts/banner.html >> $(TMPFILE)
	cat html-parts/nav-bar.html >> $(TMPFILE)
	cat $< >> $(TMPFILE) # add body
	cat html-parts/footer.html >> $(TMPFILE)
	echo \<\/body\> >> $(TMPFILE)
	echo \<\/html\> >> $(TMPFILE)
	pandoc -f markdown -t html -o $@ $(TMPFILE)
	rm $(TMPFILE)
endef

.PHONY : all

.PHONY : clean

# want output directory layout as follows:
# The output directory becomes webroot when processed by travis
# out/index.html
# out/about.html
# out/contact.html
# out/projects.html
# out/projects/*
# out/wiki/*
# out/blog-contents/*


all : $(WHTML) $(BHTML) $(OHTML)

$(OUTDIR) :
	mkdir $(OUTDIR)

$(TMPDIR) :
	mkdir $(TMPDIR)

$(WIKIDIR) : | $(OUTDIR)
	mkdir $(OUTDIR)/$(WIKIDIR)

$(BLOGDIR) : | $(OUTDIR) # pipe to use order only prereqs
		mkdir $(OUTDIR)/$(BLOGDIR)

# order is as follows
# - head.html This file contains the html declaration and stylesheet info
# - title
# - insert <body> tag here
# - generic/banner.html This contains the website banner
# - generic/nav-bar.html This contains the nav bar for all pages
# - page-specific/page-body.html This contains the main page body
# - generic/footer.html this contains the footer for all pages
# - insert </body> tag here
# - insert </html> tag here

$(WHTML)/%.html : $(WSOURCES)/%.md | $(WIKIDIR) $(OUTDIR) $(TMPDIR)
	$(sequence)

$(BHTML)/%.html : $(BSOURCES)/%.md | $(BLOGDIR) $(OUTDIR) $(TMPDIR)
	$(sequence)

$(PHTML)/%.html : $(PSOURCES)/%.md | $(PROJDIR) $(OUTDIR) $(TMPDIR)
	$(sequence)

about.html : $(OSOURCES)/about.md | $(OUTDIR) $(TMPDIR)
	$(sequence)

contact.html : $(OSOURCES)/contact.md | $(OUTDIR) $(TMPDIR)
	$(sequence)

index.html : $(OSOURCES)/index.md | $(OUTDIR) $(TMPDIR)
	$(sequence)

projects.html : $(OSOURCES)/index.md | $(OUTDIR) $(TMPDIR)
	$(sequence)
