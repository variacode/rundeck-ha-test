# rundeck-ha-test

## after clonning

- git submodule init
- git submodule update

## to build rundeck image

- docker build -t rdeck . 
- docker run --rm -it rdeck bash

## TODO LIST LONG VERSION

1. [X] hacer que ambos rundecks miren a la misma base de datos
    1. https://github.com/ahonor/rundeck-vagrant/tree/master/primary-secondary-failover
    2. https://github.com/ahonor/rundeck-vagrant/blob/master/primary-secondary-failover/install-rundeck.sh
    3. http://support.simplifyops.com/customer/portal/articles/2066438-install-pro-ha
2. [X] que inicien en modo cluster
    1. http://support.simplifyops.com/customer/portal/articles/2066438-install-pro-ha
3. [ ] que compartan los logs
4. instaler ssh en los dockers?
    1. https://docs.docker.com/engine/admin/using_supervisord/
    2. supervisord puede lanzar tu wea como servicio
    3. si instals esto con nodervisor vas a poder parar tambien los servicios!!
5. agregar un balanceador a los dockers
    1. https://slack-redir.net/link?url=http%3A%2F%2Fwww.tokiwinter.com%2Fhighly-available-load-balancing-of-apache-tomcat-using-haproxy-stunnel-and-keepalived%2F&v=3
6. agregar un servidor web con las tareas para comprobar que todo anda o no
    1. este servidor necesita un index.html donde especifique los demas recursos de la prueba

