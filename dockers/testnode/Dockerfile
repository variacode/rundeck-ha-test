FROM ubuntu:16.04

# (Optional) Change apt repository
#RUN sed -i.bak -e "s:archive.ubuntu.com:ftp.tecnoera.com:g" /etc/apt/sources.list

## General package configuration
RUN apt-get -y update && \
    apt-get -y install \
        sudo \
        unzip \
        curl \
        iputils-ping
#        xmlstarlet \
#        git \
#        netcat-traditional \
#        software-properties-common \
#        debconf-utils \
#        uuid-runtime \
#        ncurses-bin

## Install Oracle JVM
#RUN add-apt-repository -y ppa:webupd8team/java && \
#  apt-get update && \
#  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && \
#  apt-get install -y oracle-java8-installer

## Set up env
ENV USERNAME=rundeck \
    HOME=/home/rundeck

## Create rundeck user
RUN adduser --shell /bin/bash --home $HOME --gecos "" --disabled-password $USERNAME && \
    passwd -d $USERNAME && \
    addgroup $USERNAME sudo

## Copy files
RUN mkdir -p $HOME/var/logs
VOLUME $HOME/var/log

#COPY rdpro-installer $HOME/rdpro-installer
#COPY rundeckpro-installer $HOME/rundeckpro-installer
COPY scripts/* $HOME/

RUN chown -R $USERNAME:$USERNAME $HOME && \
    chmod +x $HOME/*.sh $HOME/


# Set Run Context
USER $USERNAME
WORKDIR $HOME
VOLUME $HOME

#CMD $HOME/run.sh
CMD sudo chown -R $USERNAME:$USERNAME $HOME && \
    sudo tail -F /var/log/dmesg
