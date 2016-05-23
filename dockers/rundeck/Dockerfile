FROM ubuntu:16.04

## http://stackoverflow.com/questions/20635472/using-the-run-instruction-in-a-dockerfile-with-source-does-not-work
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# (Optional) Change apt repository
RUN sed -i.bak -e "s:archive.ubuntu.com:ftp.tecnoera.com:g" /etc/apt/sources.list

## General package configuration
RUN apt-get -y update && \
    apt-get -y install \
        sudo \
        unzip \
        curl \
        xmlstarlet \
        git \
        netcat-traditional \
        software-properties-common \
        debconf-utils \
        uuid-runtime \
        ncurses-bin && \
    apt-get -y autoremove

## Install Oracle JVM
RUN \
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer

## DEBUG ENV VARS AT THIS POINT
RUN echo "**** ENV VARS START ****" && printenv > /env_at_build_time && cat /env_at_build_time && echo "**** ENV VARS END ****"

# SSH SERVER
RUN apt-get install -yqq openssh-server
RUN mkdir -p /var/run/sshd

# SUPERVISOR
RUN apt-get -yqq install supervisor 
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# RUNDECK

## RUNDECK setup env
ENV USERNAME=rundeck \
    HOME=/home/rundeck

# RUNDECK - create user
RUN adduser --shell /bin/bash --home $HOME --gecos "" --disabled-password $USERNAME && \
    passwd -d $USERNAME && \
    addgroup $USERNAME sudo

COPY rundeckpro-installer $HOME/rundeckpro-installer
COPY install-and-run.sh $HOME/install-and-run.sh

RUN chown -R $USERNAME:$USERNAME $HOME
RUN chmod +x $HOME/install-and-run.sh

# RUNDECK - building installer
ENV LOGNAME=$USERNAME TERM=xterm-256color
WORKDIR $HOME/rundeckpro-installer
RUN sed -i.bak -e "s|securerandom.source=file:/dev/random|securerandom.source=file:/dev/urandom|" /usr/lib/jvm/java-8-oracle/jre/lib/security/java.security && \
    ./build.sh --notests --bundle && \
    mv -fv rdpro-installer $HOME/rdpro-installer && \
    rm -rf /tmp/it_* /tmp/rdpro* /tmp/RDECK*


# RUNDECK - installation
WORKDIR $HOME
USER rundeck

RUN ./rdpro-installer install-all \
      --java-opts "-Djava.security.egd=file:/dev/./urandom" \
      --http-port 4440 \
      --https-port 4443 \
      --keystore-generate true \
      --keystore-file $HOME/etc/truststore \
      --keystore-pass rundeck \
      --keystore-dname 'CN=acme.org,OU=CA,O=ACME,L=Acme,S=Acme,C=US' \
      --datasource-driver com.mysql.jdbc.Driver \
      --datasource-url 'jdbc:mysql://mysql/rundeck?autoReconnect=true' \
      --datasource-username rundeck \
      --datasource-password rundeck \
      --server-url "http://loadbalancer:80/rundeckpro-dr"

RUN ./rdpro-installer configure-clustermode \
  --enabled true \
  --rdeck-base $HOME

RUN ./rdpro-installer configure-logs-dir \
  --logs-dir /logs \
  --rdeck-base $HOME

EXPOSE 22 3000 4440 4443

USER root
ENTRYPOINT ["/usr/bin/supervisord"]
