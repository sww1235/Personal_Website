WIKIDIR=wiki
BLOGDIR=blog-contents
OTHERDIR=other-pages
PROJDIR=projects
OUTDIR=www
TMPDIR=tmp

WSOURCES = $(wildcard $(WIKIDIR)/*.md)
BSOURCES = $(wildcard $(BLOGDIR)/*.md)
PSOURCES = $(wildcard $(PROJDIR)/*.md)
OSOURCES = $(wildcard $(OTHERDIR)/*.md)

WHTML = $(patsubst $(WIKIDIR)/%.md,$(OUTDIR)/$(WIKIDIR)/%.html,$(WSOURCES))
BHTML = $(patsubst $(BLOGDIR)/%.md,$(OUTDIR)/$(BLOGDIR)/%.html,$(BSOURCES))
PHTML = $(patsubst $(PROJDIR)/%.md,$(OUTDIR)/$(PROJDIR)/%.html,$(PSOURCES))
OHTML = $(addprefix $(OUTDIR)/,about.html contact.html index.html projects.html)

define sequence
	# create temporary markdown file
	@echo $@
	@echo $<
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

.PHONY : test

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
	mkdir $(OUTDIR)/$(WIKIDIR)
	mkdir $(OUTDIR)/$(BLOGDIR)
	mkdir $(OUTDIR)/$(PROJDIR)

$(TMPDIR) :
	mkdir $(TMPDIR)

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

clean :
	rm -rf $(OUTDIR)
	rm -rf $(TMPDIR)


test :
	@echo wiki
	@echo $(WHTML)
	@echo $(WSOURCES)
	@echo blog
	@echo $(BHTML)
	@echo $(BSOURCES)
	@echo projects
	@echo $(PHTML)
	@echo $(PSOURCES)
	@echo other
	@echo $(OHTML)
	@echo $(OSOURCES)

# pipe to use order only prereqs

$(WHTML) : $(OUTDIR)/$(WIKIDIR)/%.html : $(WIKIDIR)/%.md |  $(OUTDIR) $(TMPDIR)
	@echo wiki
	@echo $@
	@echo $<
	$(sequence)

$(BHTML) : $(OUTDIR)/$(BLOGDIR)/%.html : $(BLOGDIR)/%.md |  $(OUTDIR) $(TMPDIR)
	@echo blog
	$(sequence)

$(PHTML) : $(OUTDIR)/$(PROJDIR)/%.html : $(PROJDIR)/%.md |  $(OUTDIR) $(TMPDIR)
	@echo projects
	$(sequence)

$(OHTML) : $(OUTDIR)/%.html : $(OTHERDIR)/%.md | $(OUTDIR) $(TMPDIR)
	@echo others
	$(sequence)
#
# about.html : $(OTHERDIR)/about.md | $(OUTDIR) $(TMPDIR)
# 	$(sequence)
#
# contact.html : $(OTHERDIR)/contact.md | $(OUTDIR) $(TMPDIR)
# 	$(sequence)
#
# index.html : $(OTHERDIR)/index.md | $(OUTDIR) $(TMPDIR)
# 	$(sequence)
#
# projects.html : $(OTHERDIR)/index.md | $(OUTDIR) $(TMPDIR)
# 	$(sequence)
