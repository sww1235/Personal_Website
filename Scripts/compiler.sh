#! /bin/bash

# to run for my website, use the below command run in the Personal_Website directory
# ./scripts/compiler.sh . ../sww1235.github.io/

# this concatinates the various html scraps together into functional webpages

# There must be a page-head and page-body in order for the full page to be
# generated corectly

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

rm $2/*.html

# cd $1 || exit

pages=($(find . -name "*-head.html"|cut -d'/' -f 4|cut -d'-' -f 1))

# for ((i=0;i<${#pages[@]};i++));
# do
#   echo "${pages[i]}" #| tr '\n' 't'
# done



heads=($(find . -name "*-head.html"))
bodies=($(find . -name "*-body.html"))

banner=$(find . -name "banner.html")
footer=$(find . -name "footer.html")
head=$(find . -name "head.html")
nav=$(find . -name "nav-bar.html")
#echo $test

for ((i=0;i<${#pages[@]};i++));
do

  if [[ "${pages[i]}" == $'\n' ]]; then # !  -z  "${pages[i]}" ||
    echo "skipping" "${pages[i]}"
    continue
  fi
  echo "${pages[i]}"
  cat $head ${heads[i]} >> "$2/${pages[i]}.html"
  #read -n1 -r -p "Press any key to continue..."
  echo "<body>" >> "$2/${pages[i]}.html"
  #read -n1 -r -p "Press any key to continue..."
  cat $banner $nav ${bodies[i]} $footer >> "$2/${pages[i]}.html"
  #read -n1 -r -p "Press any key to continue..."
  echo "</body>" >> "$2/${pages[i]}.html"
  echo "</html>" >> "$2/${pages[i]}.html"
done
