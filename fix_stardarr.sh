#!/bin/bash

# servarr installer script doesn't seem to take target dirs
# create a script to fix afterwards

#set -x
set -ueo pipefail

DEFAULT_OPT=/opt
MY_OPT=/hoard/opt

DEFAULT_LIB=/var/lib
MY_LIB=/hoard/opt

LN=/usr/bin/ln
RM=/usr/bin/rm
RSYNC=/usr/bin/rsync
RSYNC_OPTS="-aq"


fix_dir() {
	local _darr=$1
	local _dir=$2
	local _wrong_dir=$3
	local _right_dir=$4

	echo "Fixing ${_darr} ${_dir}."
	if [[ ! -e "${_wrong_dir}" ]]
	then
		echo "${_darr} ${_dir} doesn't exist, skipping."
		return
	fi
	if [[ ! -d "${_wrong_dir}" ]]
	then
		echo "${_darr} ${_dir} isn't a directory, skipping."
		return
	fi
	if [[ -h "${_wrong_dir}" ]]
	then
		echo "${_darr} ${_dir} already seems fixed, skipping."
		return
	fi
	echo "Syncing files:"
	${RSYNC} "${RSYNC_OPTS}" "${_wrong_dir}" "${_right_dir}"
	echo "Deleting dir:"
	${RM} -rf "${_wrong_dir}"
	echo "Symlinking dir:"
	${LN} -s "${_right_dir}" "${_wrong_dir}"
	echo "${_darr} fixed."
}


for darr in Lidarr Prowlarr Radarr Readarr Sonarr
do
	lower_darr=${darr,,}
	opt_src=${DEFAULT_OPT}/${darr}
	opt_dst=${MY_OPT}/${lower_darr}/${darr}

	lib_src=${DEFAULT_LIB}/${lower_darr}
	lib_dst=${MY_LIB}/${lower_darr}/data

	fix_dir "${darr}" "opt" "$opt_src" "$opt_dst"
	fix_dir "${darr}" "lib" "$lib_src" "$lib_dst"

done



