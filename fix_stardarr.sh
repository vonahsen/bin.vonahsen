#!/bin/bash

# set -x
set -ueo pipefail

DEFAULT_OPT=/opt
MY_OPT=/hoard/opt

DEFAULT_LIB=/var/lib
MY_LIB=/hoard/opt

LN=/usr/bin/ln
RM=/usr/bin/rm
RSYNC=/usr/bin/rsync
RSYNC_OPTS="-naq"


fix_opt() {
	local _darr=$1
	local _lower_case_darr=$2
	local _src=${DEFAULT_OPT}/${_darr}
	local _dst=${MY_OPT}/${_lower_case_darr}/${_darr}

	echo "Fixing ${_darr} opt."
	echo "Syncing files:"
	${RSYNC} ${RSYNC_OPTS} "${_src}" "${_dst}"
	echo "Deleting dir:"
	${RM} -rf "${_src}"
	echo "Symlinking dir:"
	${LN} -s "${_dst}" "${_src}"
	echo "${_darr} fixed."
}

fix_lib() {
	local _darr=$1
	local _lower_case_darr=$2
	local _src=${DEFAULT_LIB}/${_lower_case_darr}
	local _dst=${MY_LIB}/${_lower_case_darr}/data

	echo "Fixing ${_darr} lib."
	echo "Syncing files:"
	${RSYNC} ${RSYNC_OPTS} "${_src}" "${_dst}"
	echo "Deleting dir:"
	${RM} -rf "${_src}"
	echo "Symlinking dir:"
	${LN} -s "${_dst}" "${_src}"
	echo "${_darr} fixed."
}


for darr in Lidarr Prowlarr Radarr Readarr Sonarr
do
	lower_darr=${darr,,}
	fix_opt "$darr" "$lower_darr"
	fix_lib "$darr" "$lower_darr"

done


