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
    1. https://github.com/ahonor/rundeck-vagrant/blob/master/primary-secondary-failover/install-rundeck.sh
    1. http://support.simplifyops.com/customer/portal/articles/2066438-install-pro-ha
1. que inicien en modo cluster [X]
    1. http://support.simplifyops.com/customer/portal/articles/2066438-install-pro-ha
1. que compartan los logs [X]
1. agregar un balanceador a los dockers [X]
    1. [Rundeck instructions about HA are HERE!!](http://support.simplifyops.com/customer/portal/articles/2066438-install-pro-ha)
    1. [Ejemplo que Luis usó para montar un load balancer](https://slack-redir.net/link?url=http%3A%2F%2Fwww.tokiwinter.com%2Fhighly-available-load-balancing-of-apache-tomcat-using-haproxy-stunnel-and-keepalived%2F&v=3)
    1. [Using nginx as a load balancer](http://nginx.org/en/docs/http/load_balancing.html)
    1. [nginx Docker image](https://hub.docker.com/_/nginx/)
1. instaler ssh en los dockers? -- RP:ongoing
    1. [Using supervisord in Docker by Docker dudes](https://docs.docker.com/engine/admin/using_supervisord/)
    1. supervisord puede lanzar tu wea como servicio
    1. si instals esto con nodervisor vas a poder parar tambien los servicios!!
1. respecto de lanzar todo esto desde gradle
    1. [Un Hipster, probablemente, en San Francisco. hablando de lo que queremos hacer](https://www.youtube.com/watch?v=8QbKXPWpyKs)
    1. [Otra charla, no se realmente si sera buena o no](http://www.nljug.org/jfall/session/how-to-use-docker-compose-and-gradle-to-continousl/171/)
    1. [Este plugin de gradle parece ser lo que buscamos](https://github.com/palantir/gradle-docker)
    1. [otro plugin de gradle ya hecho](https://github.com/avast/docker-compose-gradle-plugin)
1. Crear el proyecto, el nodo y la tarea en el rundeck clusterizado
1. ¿Cómo sabremos si este test es o no exitoso en una manera programatica?



la idea seria seguir este ejemplo https://github.com/ahonor/rundeck-vagrant/tree/master/primary-secondary-failover, hay que fijarse
en el orden que impone este archivo https://github.com/ahonor/rundeck-vagrant/blob/master/primary-secondary-failover/Vagrantfile

en este momento nosotros tenemos dos rundecks iguales hay que, igualar el comportamiento de https://github.com/ahonor/rundeck-vagrant/blob/master/primary-secondary-failover/add-primary.sh
y los demas scripts!!

si te fijas el add-primary deberia ejecutarse en el docker2 con el docker1 como argumento, esto quiere decir NECESITAMOS ssh
