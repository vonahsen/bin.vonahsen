#!/bin/bash

set -ue #o pipefail
# can't pipefail because something in the massive
# pipeline throws 141
#set -x

DNS_LOG='/var/log/pihole/pihole.log'
# SC2034 (warning): QUERY_TYPE_FIELD appears unused. Verify use (or export if used externally).
# yes, these are cruft
# shellcheck disable=SC2034
QUERY_TYPE_FIELD=5
# shellcheck disable=SC2034
QUERY_FIELD=6
# shellcheck disable=SC2034
CLIENT_FIELD=8

GREP_STR="query\["
REPORT_LINES=15
REPORT_DELIM="================================================="

AWK=/usr/bin/awk
DATE=/usr/bin/date
GREP=/usr/bin/grep
HEAD=/usr/bin/head
MAIL=/usr/bin/mail
SORT=/usr/bin/sort
UNIQ=/usr/bin/uniq
WC=/usr/bin/wc

TODAY=$(${DATE} +%Y-%m-%d)

QUERIES=$(${GREP} "${GREP_STR}" ${DNS_LOG})

TQ=$(echo "${QUERIES}" | ${WC} -l)
# SC2016 (info): Expressions don't expand in single quotes, use double quotes for that. <- these are awk quotes, not bash quotes
# shellcheck disable=SC2016
TQT=$(echo "${QUERIES}" | ${AWK} '{print $5}' | ${SORT} | ${UNIQ} -c | ${SORT} -rn | ${HEAD} -n${REPORT_LINES})
# shellcheck disable=SC2016
TL=$(echo "${QUERIES}" | ${AWK} '{print $6}' | ${SORT} | ${UNIQ} -c | ${SORT} -rn | ${HEAD} -n${REPORT_LINES})
# shellcheck disable=SC2016
TC=$(echo "${QUERIES}" | ${AWK} '{print $NF}' | ${SORT} | ${UNIQ} -c | ${SORT} -rn | ${HEAD} -n${REPORT_LINES})

#cat << END
${MAIL} -s "DNS stats ${TODAY}" "cron@vonahsen.com" << END
${REPORT_DELIM}
==     TOTAL QUERIES
${REPORT_DELIM}
${TQ}

${REPORT_DELIM}
==     TOP QUERY TYPES                           
${REPORT_DELIM}
${TQT}

${REPORT_DELIM}
==     TOP LOOKUPS                               
${REPORT_DELIM}
${TL}

${REPORT_DELIM}
==     TOP CLIENTS                               
${REPORT_DELIM}
${TC}
END

