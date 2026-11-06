# shellcheck shell=bash

abort() {
	echo "${@}" >&2
	exit 1
}
