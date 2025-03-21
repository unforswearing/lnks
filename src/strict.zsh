declare -a _env.strict=(
	setopt warn_nested_var
	setopt warn_create_global
	setopt function_argzero
	setopt no_clobber
	setopt no_append_create
	setopt no_glob
	setopt unset
)
