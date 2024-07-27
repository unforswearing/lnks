#  Not Implemented:
_pastebin() {
  _pastebin_store_credentials() {
    echo "lnks needs to store your Pastebin API Key."
    echo "You can generate an API key by creating an account at pastebin.com"
    echo "and visiting the API documentation - http://pastebin.com/api"
    sleep 1
    tput cnorm
    read -r -p "	enter your API Key: " pastebin_api
    sleep .2
    echo "done! your credentials are stored at $HOME/.lnks.conf"
    echo "delete this file at any time to revoke Pastebin access."
    sleep .2
    echo "now saving your links"
    echo -en "pastebin_api=\"$pastebin_api\"" >> ~/.lnks.conf
  }

  _pastebin_get_credentials() {
    grep -i 'pastebin_api' ~/.lnks.conf | \
    awk -F= '{print $2}' | \
    sed 's|\"||g'
  }

  if [[ "$(grep 'pastebin_api' ~/.lnks.conf)" ]]; then
    pastebin_api=$(_pastebin_get_credentials)
  else
    _pastebin_store_credentials
  fi
}

_pastebin_curl() {
  _do_curl() {
    curl -s \
      -F "api_dev_key=$pastebin_api" \
      -F "api_option=paste" \
      -F "api_paste_code=$lnx" \
      http://pastebin.com/api/api_post.php
  }

  local lnx=$(links)

  if [[ $lnx == "Error: No matching links" ]]; then
    links;
    exit 1;
  else
    echo 'your links are available at:'
    _do_curl
    printf '\n'
  fi
}