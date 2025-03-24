# examples.bash
# lnks [option [option]] <search term>
# view help
lnks --help
lnks --print "github.com"
# output: 
# links matching 'github.com'
# https://github.com/unfoswearing/lnks
# https://github.com/unfoswearing
# copy matching links to your clipboard
# output: Links matching 'github.com' are copied to the clipboard.
lnks --copy"github.com"
# print maching urls as formatted markdown links
# output: [lnks](https://github.com/unfoswearing/lnks)
lnks --markdown "github.com"
# save the content of matching urls to pdf
# output: The content matching 'github.com' is saved to 'myurl.pdf'.
lnks --pdf myurl.pdf "github.com" 
# lnks --urls inputurls.txt --<option>
# read urls from a file and run a lnks option for each
# output: Content from urls in 'inputurls.txt' is saved to pdf.
lnks --urls inputurls.txt --pdf
lnks --urls <(lnks --print "github.com") --pdf

