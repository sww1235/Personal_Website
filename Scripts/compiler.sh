#! /bin/bash

# this concatinates the various html scraps together into functional webpages

# order is as follows
# - generic/head.html This file contains the html declaration and stylesheet info
# - page-specific/page-head.html This file contains the <head></head> for a particular page.
# - insert <body> tag here
# - generic/banner.html This contains the website banner
# - generic/nav-bar.html This contains the nav bar for all pages
# - page-specific/page-body.html This contains the main page body
# - generic/footer.html this contains the footer for all pages
# - insert </body> tag here
# - insert </html> tag here

if [ $# -eq 0 ]; then
  echo $0 "Usage: input-directory output-directory"
  exit
fi

cd $1


for file in files
do
  echo "test"
done
