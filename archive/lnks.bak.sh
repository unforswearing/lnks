#!/bin/bash

# To Do
# - add option to read urls from a file and run a single command for all
#   - eg. lnks -r urls.txt --instapaper
# - improve code quality and style consistency
#   - to inlcude renaming functions and changing the case statment to use 'getopts'
# - extract pastebin functions into a standalone file as a 'plugin'
# - remove all commented code
#

lnks() {
	OIFS="$IFS"
	IFS=$'\n\t'

	local option; option="$1"
	local srch; srch="$2"
	local lfile; lfile="$3"

	# https://www.w3.org/Tools/HTML-XML-utils/README
	local hxclean; hxclean="$(command -v hxclean)"
	local hxselect; hxselect="$(command -v hxselect)"

	_lnx_help() {
		echo "lnks <option> <search term>"
		echo
		echo "Options:"
		echo "  -s|--save       save the links to a file on the desktop"
		echo "  -c|--copy       copy the links to your clipboard"
		echo "  -p|--print      print the links to stdout"
		echo "  -m|--markdown		print links in mardown format: [title](url)"
		echo "  -i|--instapaper save the link(s) to instapaper"
		echo "  -b|--pinboard   save the link(s) to pinboard.in (requires 'html-xml-utils')"
		echo "  -w|--pdf        save each url as a pdf (requires 'wkhtmltopdf')"
		echo "  -h|--help       print this help message"
		echo
		echo "Note"
		echo "  - one (and only one) option is permitted. lnks will fail if multiple options are specified."
		echo "    - lnks will allow multiple options in a future version"
	}

	_htmlxmlutil_warning() {
		echo "Error: hxclean or hxselect is not installed, or they are not in your \$PATH"
		echo "Please visit https://www.w3.org/Tools/HTML-XML-utils/README for installation information"
		echo "or install the 'html-xml-utils' package via homebrew (https://brew.sh)"
	}

	_prog() {
		[[ -z "$1" ]] && exit 0

		set +m
		tput civis

		eval "$1" >/dev/null 2>&1 &

		local pid; pid=$!
		local spin; spin="-\|/"
		local i; i=0

		while kill -0 "$pid" 2>/dev/null; do
			i=$(((i + 1) % 4))
			printf "\r%s" ${spin:$i:1}
			sleep .07
		done
		printf "\r"

		tput cnorm
		set -m
	}

	links() {
		_pull() {
			osascript <<EOT
				tell application "Google Chrome"
					set links to get URL of tabs of first window
					return links
				end tell
EOT
		}

		local count; count="$(_pull | grep -i "$srch" | sed "s|^ ||g" | wc -l)"
		local links; links="$(_pull | tr ',' '\n' | grep -i "$srch" | sed "s|^ ||g")"

		if [[ "$count" -eq 0 ]]; then
			echo "Error: No matching links"
		else
			echo "$links"
		fi

		unset count
		unset links
	}

	_save() {
		if [[ -z "$lfile" ]]; then
			echo "No filename entered."
			_lnx_help
		fi

		links > "$lfile" && echo "Links matching $srch saved to $lfile"
		unset -f _save
	}

	_copy() {
		copylinks() {
			links | pbcopy
			echo "Links matching $srch copied to clipboard"
		}

		local lnx
		lnx="$(links)"

		if [[ "$lnx" == "Error: No matching links" ]]; then
			links
		else
			copylinks
		fi

		unset -f _copy
	}

	_markdown() {
		if [[ -z "$hxclean" ]] || [[ -z "$hxselect" ]]; then
			_htmlxmlutil_warning
		else
			links | while read -r lnk; do
				local title; title="$(curl "${lnk}" -so - | "$hxclean" | "$hxselect" -s '\n' -c 'title')"
				echo -en "[${title}](${lnk})\n"
			done
		fi

		unset -f _markdown
	}

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
				echo "instapaper_username=\"$instapaper_username\"";
				echo "instapaper_password=\"$instapaper_password\"";
				echo;
			} >> ~/.lnks.conf

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

		unset instapaper_username
		unset instapaper_password
		unset -f _instapaper
		unset -f _instapaper_add
	}

	_pinboard() {
		_pinboard_get_credentials() {
			pinboard_api="$(grep -i 'pinboard_api' ~/.lnks.conf | awk -F= '{print $2}' | sed 's|\"||g')"
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
				title="$(curl -so - "$url" | "$hxclean" | "$hxselect" -s '\n' -c 'title')"
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

		unset pinboard_api
		unset -f _pinboard
		unset -f _pinboard_add
	}

	_wkhtmltopdf() {
		_to_pdf() {
			"$(command -v wkhtmltopdf)" --quiet --title "$url" "$url" "$title".pdf
			sleep .2
		}

		# test for the existense of wkhtmltopdf
		if [[ ! "$(command -v wkhtmltopdf)" ]]; then
			echo "Error: wkhtmltopdf is not installed, or it is not in your \$PATH"
			echo "Please visit http://wkhtmltopdf.org/downloads.html for installation instructions"
		else
			local lnx; lnx="$(links | tr ' ' '\n')"

			while read -r url; do
				echo "Converting \"${url}\" to PDF..."
				_prog _to_pdf

				local title
				title="$(
					readonly hxclean="$(command -v hxclean)";
					readonly hxselect="$(command -v hxselect)";
					curl -so - "$url" | $hxclean | "$hxselect" -s '\n' -c 'title'
				)"

				echo "Done - $(pwd)/${title}.pdf"
			done < <(echo "$lnx")
		fi

		unset -f _wkhtmltopdf
	}

	if [[ "$option" == "-h" ]]; then
		:
	elif [[ ! "$option" ]]; then
		:
	elif [[ "$srch" == "" ]]; then
		echo "Error: No search term entered"
		option="--help"
	fi

	case "$option" in
		# help
		--help | -h) _lnx_help ;;
		"") _lnx_help ;;
		# option to save the list as a file
		--save | -s) _save ;;
		# copy to clipboard
		--copy | -c) _copy ;;
		# print
		--print | -p) links ;;
		# print markdown formatted links
		--markdown | -m) _markdown ;;
		# add to instapaper
		--instapaper | -i) _instapaper && _instapaper_add ;;
		# save to pinboard
		--pinboard | -b) _pinboard && _pinboard_add ;;
		# save url (as webpage) to pdf
		--pdf | -w) _wkhtmltopdf ;;
		*) _lnx_help ;;
	esac

	# take only memories, leave no footprints
	{
		unset url
		unset -f links; unset -f _lnx_help; unset -f _s
		unset -f _c; unset -f _instapaper; unset -f _instapaper_add
		unset -f _pinboard; unset -f _pinboard_add; unset -f _w

		IFS="$OIFS"

		unset -f erase
	} >/dev/null 2>&1
}