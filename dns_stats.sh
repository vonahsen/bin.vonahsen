#!/bin/bash

set -ue #o pipefail
# can't pipefail because something in the massive
# pipeline throws 141
#set -x

DNS_LOG='/var/log/pihole/pihole.log'
QUERY_TYPE_FIELD=5
QUERY_FIELD=6
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
TQT=$(echo "${QUERIES}" | ${AWK} '{print $5}' | ${SORT} | ${UNIQ} -c | ${SORT} -rn | ${HEAD} -n${REPORT_LINES})
TL=$(echo "${QUERIES}" | ${AWK} '{print $6}' | ${SORT} | ${UNIQ} -c | ${SORT} -rn | ${HEAD} -n${REPORT_LINES})
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

