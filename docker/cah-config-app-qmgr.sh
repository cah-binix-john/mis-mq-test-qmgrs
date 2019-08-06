#!/bin/bash
set +e

cp /etc/mqm/qm-secret/key* /var/mqm/qmgrs/${MQ_QMGR_NAME}/ssl/

MQ_ACE_USERNAME=$(cat /etc/mqm/qm-creds/MQ_ACE_USERNAME)
MQ_ACE_PASSWORD=$(cat /etc/mqm/qm-creds/MQ_ACE_PASSWORD)

groupadd --system --gid 10005 mqace
useradd  -u 10005 -G 10001 -g 10005 ${MQ_ACE_USERNAME} 
echo ${MQ_ACE_USERNAME}:${MQ_ACE_PASSWORD} | /usr/sbin/chpasswd

runmqsc ${MQ_QMGR_NAME} << EOF
ALTER QMGR CERTLABL('${MQSC_CERTLABL}')
******************************************************************************
DEFINE CHANNEL ('INFRA.ADMIN.SVRCONN') CHLTYPE(SVRCONN) LIKE(SYSTEM.DEF.SVRCONN) MCAUSER('NOACCESS') MAXINST(1000) MAXINSTC(1000) SSLCAUTH(REQUIRED) SSLCIPH('${MQSC_SSLCIPH}') REPLACE
SET CHLAUTH('INFRA.ADMIN.SVRCONN') TYPE (SSLPEERMAP) ACTION(REMOVEALL)
SET CHLAUTH('INFRA.ADMIN.SVRCONN') TYPE (SSLPEERMAP) SSLPEER('${MQSC_SSLPEER}') USERSRC(MAP) MCAUSER('mqm') ACTION(ADD)
******************************************************************************
DEFINE CHANNEL (APP.ACE.SVRCONN) CHLTYPE(SVRCONN) LIKE(SYSTEM.DEF.SVRCONN) MCAUSER('NOACCESS') REPLACE
SET CHLAUTH('APP.ACE.SVRCONN') TYPE(USERMAP) CLNTUSER('${MQ_ACE_USERNAME}') USERSRC(MAP) MCAUSER('mqm') CHCKCLNT(REQUIRED) ACTION(ADD)
*******************************************************************************
DEFINE QREMOTE('INFRA.TEMPLATE.REMOTE.GM1') RQMNAME('${MQSC_GM_ALIAS}') DESCR('CAH template cluster queue for Med Gateway') REPLACE
DEFINE QREMOTE('INFRA.TEMPLATE.REMOTE.GP1') RQMNAME('${MQSC_GP_ALIAS}') DESCR('CAH template cluster queue for Pharma Gateway') REPLACE
DEFINE QLOCAL('INFRA.TEMPLATE.LOCAL.MCLUS01') BOTHRESH(3) CLUSTER('${MQSC_MCLUS}') DESCR('CAH template cluster queue in MCLUS01') DISTL(NO) MAXDEPTH(1000) M
AXMSGL(1048576) REPLACE
****************************
REFRESH SECURITY
REFRESH SECURITY TYPE(SSL)
******************************************************************************
EOF

for MQSC_FILE in $(ls -v /etc/mqm/*.mqsc); do
  runmqsc ${MQ_QMGR_NAME} < ${MQSC_FILE}
done

#tail -f /var/mqm/qmgrs/$MQ_QMGR_NAME/errors/AMQERR01.LOG

# Turn back on script failing here
set -e
