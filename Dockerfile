FROM ubuntu:16.04

# (Optional) Change apt repository
RUN sed -i.bak -e "s:archive.ubuntu.com:ftp.tecnoera.com:g" /etc/apt/sources.list


## General package configuration
RUN apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y autoremove && \
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
        ncurses-bin

## Install Oracle JVM
RUN add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && \
  apt-get install -y oracle-java8-installer

## Set up env
ENV USERNAME=rundeck \
    HOME=/home/rundeck

## Create rundeck user
RUN adduser --shell /bin/bash --home $HOME --gecos "" --disabled-password $USERNAME && \
    passwd -d $USERNAME && \
    addgroup $USERNAME sudo

## Copy files
#COPY rdpro-installer $HOME/rdpro-installer
COPY rundeckpro-installer $HOME/rundeckpro-installer
COPY scripts/install-and-run.sh $HOME/install-and-run

RUN chown -R $USERNAME:$USERNAME $HOME && \
    chmod +x $HOME/install-and-run $HOME/

#Build installer
ENV LOGNAME=$USERNAME TERM=xterm-256color
WORKDIR $HOME/rundeckpro-installer
RUN sed -i.bak -e "s|securerandom.source=file:/dev/random|securerandom.source=file:/dev/urandom|" /usr/lib/jvm/java-8-oracle/jre/lib/security/java.security && \
    ./build.sh --bundle && \
    mv -fv rdpro-installer $HOME/rdpro-installer && \
    rm -rf /tmp/it_* /tmp/rdpro* /tmp/RDECK*

# Set Run Context
USER $USERNAME
WORKDIR $HOME
VOLUME $HOME

CMD $HOME/install-and-run
