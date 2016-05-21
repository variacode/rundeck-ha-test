#!/bin/bash

# Check env
# if [[ ! $PORT ]] ; then PORT=4440 ; fi
# if [[ ! $RUNDECK_NODE ]] ; then RUNDECK_NODE=rundeck1 ; fi

# esto es necesario para compartir los archivos, deberiamos llevarnos esto a otro servicio
sudo chown -R rundeck:rundeck /logs

./rdpro-installer install-all \
  --java-opts "-Djava.security.egd=file:/dev/./urandom" \
  --http-port $HTTP_PORT \
  --https-port $HTTPS_PORT \
  --keystore-generate true \
  --keystore-file $HOME/etc/truststore \
  --keystore-pass rundeck \
  --keystore-dname 'CN=acme.org,OU=CA,O=ACME,L=Acme,S=Acme,C=US' \
  --datasource-driver com.mysql.jdbc.Driver \
  --datasource-url 'jdbc:mysql://mysql/rundeck?autoReconnect=true' \
  --datasource-username rundeck \
  --datasource-password rundeck \
  --server-name $RUNDECK_NODE \
  --server-url "http://loadbalancer:80/rundeckpro-dr"

## --server-url "http://$RUNDECK_NODE:$PORT/rundeckpro-dr"
### --server-url "https://$SERVER_VIP:4443/runseckpro"
### --server-hostname "https://$SERVER_VIP:4443/runseckpro"

# Enable clustermode
./rdpro-installer configure-clustermode \
  --enabled true \
  --rdeck-base $HOME

# agregar configure-uuid para las conf de HA
./rdpro-installer configure-logs-dir \
  --logs-dir /logs \
  --rdeck-base $HOME

./rdpro-installer start --rdeck-base $HOME \
  && tail -F $HOME/server/logs/catalina.out

