#!/bin/bash
#
# zabbix-mysql-backupconf.sh
# v0.2 - 20111105
#
# Configuration Backup for Zabbix 1.8 w/MySQL
#
# Author: Ricardo Santos (rsantos at gmail.com)
# http://zabbixzone.com
#
# Thanks for suggestions from:
# - Oleksiy Zagorskyi (zalex)
# - Petr Jendrejovsky
#

# mysql config
DBHOST="localhost"
DBNAME="zabbix"
DBUSER="zabbix"
DBPASS="YOURMYSQLPASSWORDHERE"

# some tools
MYSQLDUMP="`which mysqldump`"
GZIP="`which gzip`"
DATEBIN="`which date`"
MKDIRBIN="`which mkdir`"

# target path
MAINDIR="/var/lib/zabbix/backupconf"
DUMPDIR="${MAINDIR}/`${DATEBIN} +%Y%m%d%H%M`"
${MKDIRBIN} -p ${DUMPDIR}

# configuration tables
CONFTABLES=( actions applications autoreg_host conditions config dchecks dhosts \
drules dservices escalations expressions functions globalmacro graph_theme \
graphs graphs_items groups help_items hostmacro hosts hosts_groups \
hosts_profiles hosts_profiles_ext hosts_templates housekeeper httpstep \
httpstepitem httptest httptestitem ids images items items_applications \
maintenances maintenances_groups maintenances_hosts maintenances_windows \
mappings media media_type node_cksum nodes opconditions operations \
opmediatypes profiles proxy_autoreg_host proxy_dhistory proxy_history regexps \
rights screens screens_items scripts service_alarms services services_links \
services_times sessions slides slideshows sysmaps sysmaps_elements \
sysmaps_link_triggers sysmaps_links timeperiods trigger_depends triggers \
user_history users users_groups usrgrp valuemaps )

# tables with large data
DATATABLES=( acknowledges alerts auditlog_details auditlog events \
history history_log history_str history_str_sync history_sync history_text \
history_uint history_uint_sync trends trends_uint )

# CONFTABLES
for table in ${CONFTABLES[*]}; do
        DUMPFILE="${DUMPDIR}/${table}.sql"
        echo "Backuping table ${table}"
        ${MYSQLDUMP} -R --opt --extended-insert=FALSE \
                -h ${DBHOST} -u ${DBUSER} -p${DBPASS} ${DBNAME} --tables ${table} >${DUMPFILE}
        ${GZIP} -f ${DUMPFILE}
done

# DATATABLES
for table in ${DATATABLES[*]}; do
        DUMPFILE="${DUMPDIR}/${table}.sql"
        echo "Backuping schema table ${table}"
        ${MYSQLDUMP} -R --opt --no-data	\
                -h ${DBHOST} -u ${DBUSER} -p${DBPASS} ${DBNAME} --tables ${table} >${DUMPFILE}
        ${GZIP} -f ${DUMPFILE}
done

echo
echo "Backup Completed - ${DUMPDIR}"
