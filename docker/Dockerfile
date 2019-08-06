# version 1.1
FROM gcr.io/ent-intg-svcs-np-cah/cah-ibmmq-v9110:v1.0.2-201907120934
#FROM mq
COPY *.mqsc /etc/mqm/
COPY *.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/cah-config-app-qmgr.sh
EXPOSE 9444
#RUN ln -sf /dev/stdout /tmp/AMQERR01.LOG
