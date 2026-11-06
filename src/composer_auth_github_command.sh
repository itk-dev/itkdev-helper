# shellcheck shell=bash

auth_token="${args["--token"]:-}"

if [ -z "$auth_token" ]; then
	# Get token from 1Password
	printf "Getting token from GitHub CLI …\n"
	auth_token=$(gh auth token)
fi

if [ -z "$auth_token" ]; then
	abort "Cannot get auth token"
fi

auth_filename=auth.json
if [ ! -e "$auth_filename" ]; then
	echo "{}" >"$auth_filename"
fi

temp_filename=$(mktemp)
jq --arg auth_token "$auth_token" '.["github-oauth"].["github.com"] = $auth_token' "$auth_filename" >"$temp_filename"
mv "$temp_filename" "$auth_filename"

printf "Token added in %s.\n" "$auth_filename"

# Add auth.json to .gitignore if not already present
gitignore_line="/auth.json"
gitignore_filename=".gitignore"

if [ ! -e "$gitignore_filename" ]; then
	touch "$gitignore_filename"
fi

if ! grep --quiet --line-regexp --fixed-strings -- "$gitignore_line" "$gitignore_filename"; then
	echo "$gitignore_line" >>"$gitignore_filename"
fi
