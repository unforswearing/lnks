environ () {
	libutil:argtest "$1"
	local varname
	varname="$1" 
	if [[ -v "$varname" ]] && [[ -n "$varname" ]]
	then
		true
	else
		libutil:error.unsetvar "$1"
	fi
}
