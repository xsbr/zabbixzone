#!/bin/bash
#
# mysql-fullbackup.sh
# v0.1 - 20120921
#
# Full Backup for Zabbix w/MySQL
#
# Author: Ricardo Santos (rsantos at gmail.com)
# http://zabbixzone.com
#
MYSQLUSER="YOURUSER"
MYSQLPASS="YOURPASSWORD"

MYSQLCNF="/etc/my.cnf"
MYSQLDIR="/var/lib/mysql"

BASEDIR="/var/lib/xtrabackup"
BKPDIR="${BASEDIR}/lastbackup"
BKPTEMPDIR="${BASEDIR}/tempbackup"

# Memory used in stage 2
USEMEMORY="1GB"

# create basedir
mkdir -p ${BASEDIR}

# remove temporary dir
if [ -d "${BKPTEMPDIR}" ]; then
        rm -rf ${BKPTEMPDIR}
fi

# do backup - stage 1
innobackupex --defaults-file=${MYSQLCNF} --user=${MYSQLUSER} --no-timestamp --password=${MYSQLPASS} ${BKPTEMPDIR}

# do backup - stage 2 (prepare backup for restore)
innobackupex --apply-log --use-memory=${USEMEMORY} ${BKPTEMPDIR}

# backup my.cnf
cp -pf ${MYSQLCNF} ${BKPTEMPDIR}/my.cnf

# keep only the lastbackup
if [ -d "${BKPDIR}" ]; then
      if [ -d "${BKPDIR}.old" ]; then
              rm -rf ${BKPDIR}.old
      fi
      rm -rf ${BKPDIR}
fi
chown -R mysql: ${BKPTEMPDIR}
mv ${BKPTEMPDIR} ${BKPDIR}
