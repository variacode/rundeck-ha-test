# rundeck-ha-test

## after clonning

- git submodule init
- git submodule update

## to build rundeck image

- docker build -t rdeck . 
- docker run --rm -it rdeck bash

#### PARA loguearse a una maquina (ejemplo a rundeck2)
docker-compose exec --user rundeck rundeck2 bash -l

## TODO LIST LONG VERSION

1. hacer que ambos rundecks miren a la misma base de datos [X]
    1. https://github.com/ahonor/rundeck-vagrant/tree/master/primary-secondary-failover
    2. https://github.com/ahonor/rundeck-vagrant/blob/master/primary-secondary-failover/install-rundeck.sh
    3. http://support.simplifyops.com/customer/portal/articles/2066438-install-pro-ha
2. que inicien en modo cluster [X]
    1. http://support.simplifyops.com/customer/portal/articles/2066438-install-pro-ha
3. que compartan los logs [X]
4. agregar un balanceador a los dockers -- RP:ongoing
    1. https://slack-redir.net/link?url=http%3A%2F%2Fwww.tokiwinter.com%2Fhighly-available-load-balancing-of-apache-tomcat-using-haproxy-stunnel-and-keepalived%2F&v=3
4. instaler ssh en los dockers?
    1. https://docs.docker.com/engine/admin/using_supervisord/
    2. supervisord puede lanzar tu wea como servicio
    3. si instals esto con nodervisor vas a poder parar tambien los servicios!!
6. agregar un servidor web con las tareas para comprobar que todo anda o no
    1. este servidor necesita un index.html donde especifique los demas recursos de la prueba

