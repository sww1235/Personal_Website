#!/bin/bash

WIKIDIR=wiki
BLOGDIR=blog-contents
OTHERDIR=other-pages
PROJDIR=projects
OUTDIR=www

#VERBOSE="--verbose"

# https://www.arthurkoziel.com/convert-md-to-html-pandoc/
# use pandoc and HTML template to convert markdown files to HTML.

# First, generate navbar links, then iterate through all main directories, run
# pandoc (maybe with separate option files) and copy to appropriate directory
# within outdir.

# makefile isn't useful to only rebuild modified contents, as the output it
# would be comparing to has lost all meaningful timestamps due to using git.
# Thus we use a shell script and reduce our dependancies.  running in CI
# doesn't help with this either.

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

# first generate navbar file (included by pandoc)

# Format similar to below:
#<nav>
#    <ul>
#        <li><a href="index.html">Home</a></li>
#        <li><a href="about.html">About</a></li>
#        <li><a href="stuff.html">Stuff</a>
#            <ul>
#                <li><a href="https://github.com/sww1235">Github</a></li>
#                <li><a href="wiki/index.html">Wiki</a></li>
#
#            </ul>
#        </li>
#        <li><a href="blog-contents">Blog</a></li>
#        <li><a href="contact.html">Contact</a></li>
#
#    </ul>
#</nav>
if [ -n "${VERBOSE}" ]; then
	echo "starting to build nav-bar"
fi

navbar="html-parts/nav-bar.html"
# clear out file
: > $navbar
# then create the file anew
{
	printf '<nav id=\"topnavbar\">\n'
	printf '  <ul>\n'
	printf '    <li><a href=\"index.html\">Home</a></li>\n'
	printf '    <li><a href=\"about.html\">About</a></li>\n'
	printf '    <li><a href=\"https://github.com/sww1235\">Github</a></li>\n'

# https://stackoverflow.com/questions/5899337/proper-way-to-make-html-nested-list
	printf '    <li><a href=\"/projects/index.html\">Projects</a>\n' # don't end li element here
	printf '      <ul>\n' # insert ul element to start sublist instead
} >> $navbar

if [ -n "${VERBOSE}" ]; then
	echo "starting project loop"
fi

for file in "${PROJDIR}"/*.md; do
	if [ -n "${VERBOSE}" ]; then
		echo "$file"
	fi
	basefile=$(basename "$file" ".md")
	# want to skip index file in the sublist
	if [ "$basefile" = "index" ]; then
		continue
	fi
	# strip out dashes and upper case first letter of each word
	# https://unix.stackexchange.com/a/172207/81810
	title=$(echo "$basefile" | perl -ne 'print join " ", map { ucfirst } split /-/')
	printf '        <li><a href=\"%s/%s.html\">%s</a></li>\n' "${PROJDIR}" "$basefile" "${title}" >> $navbar
done
{
	printf '      </ul>\n' # end ul element here
	printf '    </li>\n' # end li element here instead

	# https://stackoverflow.com/questions/5899337/proper-way-to-make-html-nested-list
	printf '    <li><a href=\"/wiki/index.html\">Wiki</a>\n' >> $navbar # don't end li element here
	printf '      <ul>\n' >> $navbar # insert ul element to start sublist instead
} >> $navbar

if [ -n "${VERBOSE}" ]; then
	echo "starting wiki loop"
fi

for file in "${WIKIDIR}"/*.md; do
	if [ -n "${VERBOSE}" ]; then
		echo "$file"
	fi
	basefile=$(basename "$file" ".md")
	# want to skip index file in the sublist
	if [ "$basefile" = "index" ]; then
		continue
	fi
	# strip out dashes and upper case first letter of each word
	# https://unix.stackexchange.com/a/172207/81810
	title=$(echo "$basefile" | perl -ne 'print join " ", map { ucfirst } split /-/')
	printf '        <li><a href=\"%s/%s.html\">%s</a></li>\n' "${WIKIDIR}" "$basefile" "${title}" >> $navbar
done
{
	printf '      </ul>\n' # end ul element here
	printf '    </li>\n' # end li element here instead
} >> $navbar

# TODO: how to handle blog contents? One long string of articles or individual pages?

{
	printf '    <li><a href=\"contact.html\">Contact</a></li>\n'

	printf '  </ul>\n'
	printf '</nav>\n'
} >> $navbar

if [ -n "${VERBOSE}" ]; then
	echo "past nav-bar building"
fi

mkdir -p ${OUTDIR}
mkdir -p ${OUTDIR}/styles
mkdir -p ${OUTDIR}/${PROJDIR}
mkdir -p ${OUTDIR}/${WIKIDIR}
mkdir -p ${OUTDIR}/${BLOGDIR}

cp styles/* ${OUTDIR}/styles/

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

