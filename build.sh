#!/bin/bash

WIKIDIR=wiki
BLOGDIR=blog-contents
OTHERDIR=other-pages
PROJDIR=projects
OUTDIR=www

#VERBOSE="--verbose"

# https://www.arthurkoziel.com/convert-md-to-html-pandoc/
# use pandoc and HTML template to convert markdown files to HTML.

# iterate through all main directories, run pandoc (maybe with separate option files)
# and copy to appropriate directory within outdir.

# makefile isn't useful to only rebuild modified contents, as
# the output it would be comparing to has lost all meaningful timestamps
# due to using git. Thus we use a shell script and reduce our dependancies.
# running in CI doesn't help with this either.

# want output directory layout as follows:
# The output directory becomes webroot when processed by travis
# out/index.html
# out/about.html
# out/contact.html
# out/projects.html
# out/projects/*
# out/wiki/*
# out/blog-contents/*
# out/styles/*

mkdir -p ${OUTDIR}
mkdir -p ${OUTDIR}/styles
mkdir -p ${OUTDIR}/${PROJDIR}
mkdir -p ${OUTDIR}/${WIKIDIR}
mkdir -p ${OUTDIR}/${BLOGDIR}

# return null for failed matches in for loops
# rather than a literal *.html or whatever
shopt -s nullglob

# process wiki files

for file in "${WIKIDIR}"/*.md; do
	# ${var%string} means delete shortest match of string from var
	if [ -n "${VERBOSE}" ]; then
		echo "$file"
	fi
	basefile=$(basename "$file")
	pandoc "$VERBOSE" --defaults=pandoc-options -o "${OUTDIR}/${WIKIDIR}/${basefile%.md}.html" "$file"
done

# process project files
for file in "${PROJDIR}"/*.md; do
	# ${var%string} means delete shortest match of string from var
	if [ -n "${VERBOSE}" ]; then
		echo "$file"
	fi
	basefile=$(basename "$file")
	pandoc "$VERBOSE" --defaults=pandoc-options -o "${OUTDIR}/${PROJDIR}/${basefile%.md}.html" "$file"
done

# process blog files
for file in "${BLOGDIR}"/*.md; do
	# ${var%string} means delete shortest match of string from var
	if [ -n "${VERBOSE}" ]; then
		echo "$file"
	fi
	basefile=$(basename "$file")
	pandoc "$VERBOSE" --defaults=pandoc-options -o "${OUTDIR}/${BLOGDIR}/${basefile%.md}.html" "$file"
done

# process main files
for file in "${OTHERDIR}"/*.md; do
	# ${var%string} means delete shortest match of string from var
	if [ -n "${VERBOSE}" ]; then
		echo "$file"
	fi
	basefile=$(basename "$file")
	pandoc "$VERBOSE" --defaults=pandoc-options -o "${OUTDIR}/${basefile%.md}.html" "$file"
done

