# lnks.excluded.bash
# NOTE: THIS CODE IS NO LONGER BEING USED.
# TBD make it so all other arguments are ignored for --pdf
readonly pdf_name=$(
  awk '/--pdf/{print $0}' <<<${options[@]} \
  | fmt -1 \
  | grep -o '^[aA-zZ0-9].*pdf$'
)
if [[ -z "$pdfname ]]; then 
  lnx:lib:color red "no pdf name passed to --pdf flag"
  print "usage: lnx --pdf 'urlcontents.pdf' 'query'"
  exit 1
else
  pdf_urls "${pdf_name}"
fi
# Now to read a list of urls and perform a lnks action
# TBD make it so all other arguments are ignored for --urls
readonly url_file=$(
  awk '/--urls/{print $0}' <<<${options[@]} \
  | fmt -1 \
  | grep -o '^[aA-zZ0-9].*pdf$'
)
if [[ -z "$pdfname ]]; then 
  lnx:lib:color red "no file name passed to --urls flag"
  print "usage: lnx --urls 'urllist.txt' '--option'"
  exit 1
else
  read_urls "${url_file}" 
fi

