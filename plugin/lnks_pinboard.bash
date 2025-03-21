	_pinboard() {
		_pinboard_get_credentials() {
			pinboard_api="$(
				grep -i 'pinboard_api' ~/.lnks.conf | \
					awk -F= '{print $2}' | \
					sed 's|\"||g'
				)"
		}

		_pinboard_store_credentials() {
			echo "lnks needs to store your Pinboard API Token."
			echo -en "You can find your API Token by visiting your pinboard settings:\n"
			echo -en "https://pinboard.in/settings/password. \nYour Token will appear as"
			echo "'userName:tokenString.' For example 'lnksuser:1F4E2SD32418AF103FDD'"

			echo
			sleep 1

			tput cnorm
			read -r -p "	enter your API Key: " pinboard_api
			echo

			echo "done! your credentials are stored at $HOME/.lnks.conf"
			echo "delete this file at any time to revoke Pinboard access."
			sleep .2

			echo -en "pinboard_api=\"$pinboard_api\"" >> ~/.lnks.conf
		}

		if grep -q 'pinboard_api' ~/.lnks.conf; then
			_pinboard_get_credentials
		else
			_pinboard_store_credentials
		fi
	}

	_pinboard_add() {
		_get_info_and_post() {
			local url; url="$1"

			if [[ -z "$hxclean" ]] || [[ -z "$hxselect" ]]; then
				_htmlxmlutil_warning
			else
				local title
				title="$(
					curl -so - "$url" | \
						"$hxclean" | \
						"$hxselect" -s '\n' -c 'title'
				)"

				# if $title doesn't exist, use $url as title
				title="${title:-$url}"

				echo
				echo "TITLE: $title"
				echo "URL: $url"
				echo -en "========\n"
				echo
				echo "Enter tags for this bookmark: "

				tput cnorm
				read -r tags

				sleep 1

				local base="https://api.pinboard.in/v1/posts/add"

				curl -G --silent \
					--data-urlencode "auth_token=${pinboard_api}" \
					--data-urlencode "url=${url}" \
					--data-urlencode "description=${title}" \
					--data-urlencode "tags=${tags}" \
					"${base}" >/dev/null 2>&1

				echo "saved to pinboard!"
			fi
		}

		local lnx; lnx="$(links | tr ' ' '\n')"

		if [[ "$lnx" == "Error: No matching links" ]]; then
			links
		else
			while read -r url; do
				_get_info_and_post "$url" </dev/tty
				sleep .2
			done < <(echo "$lnx")
		fi
	}
