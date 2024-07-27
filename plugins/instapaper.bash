_instapaper() {
  _instapaper_get_credentials() {
    instapaper_username="$(
      grep -i 'instapaper_username' ~/.lnks.conf | awk -F= '{print $2}' | sed 's|\"||g'
    )"

    instapaper_password="$(
      grep -i 'instapaper_password' ~/.lnks.conf | awk -F= '{print $2}' | sed 's|\"||g'
    )"
  }

  _instapaper_store_credentials() {
    echo "lnks needs to store your Instapaper credentials"
    sleep 1

    tput cnorm
    read -r -p "enter your username (email address): " instapaper_username
    read -rs -p "	enter your password: " instapaper_password
    sleep .2

    {
      echo "instapaper_username=\"$instapaper_username\""
      echo "instapaper_password=\"$instapaper_password\""
      echo
    } >>~/.lnks.conf

    echo "done! your credentials are stored at $HOME/.lnks.conf"
    echo "delete this file at any time to revoke Instapaper access."
  }

  if grep -q 'instapaper' ~/.lnks.conf; then
    _instapaper_get_credentials
  else
    _instapaper_store_credentials
  fi
}

_instapaper_add() {
  local lnx
  lnx="$(links)"

  if [[ "$lnx" == "Error: No matching links" ]]; then
    links
  else
    links | while read -r url; do
      local base="https://www.instapaper.com/api/add"

      curl -d --silent \
        --data-urlencode "username=${instapaper_username}" \
        --data-urlencode "password=${instapaper_password}" \
        --data-urlencode "url=${url}" \
        "${base}" >/dev/null 2>&1

      echo "$url Saved!"
      sleep .2
    done
  fi
}