FROM ubuntu:16.04

# Change APT repo
#RUN sed -i.bak -e "s:archive.ubuntu.com:cl.archive.ubuntu.com:g" /etc/apt/sources.list
#general package configuration
RUN apt-get -y update && apt-get -y dist-upgrade && apt-get -y autoremove
RUN apt-get -y install \
  sudo \
  unzip \
  curl \
  xmlstarlet \
  git \
  netcat-traditional \
  software-properties-common \
  debconf-utils \
  uuid-runtime

# Install Oracle JVM
RUN add-apt-repository -y ppa:webupd8team/java && apt-get update
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && apt-get install -y oracle-java8-installer

#Set up env
ENV USER=rundeck \
    HOME=/home/rundeck \
    TOMCAT_BASE=/home/rundeck/tomcat

#create rundeck user
RUN adduser --shell /bin/bash --home ${HOME} --gecos "" --disabled-password ${USER} && passwd -d ${USER} && addgroup ${USER} sudo


#COPY ./rundeckpro-installer /home/rundeck/rundeckpro-installer
COPY rdpro-installer ${TOMCAT_BASE}/rdpro-installer
RUN chown -R ${USER}:${USER} ${HOME}
USER ${USER}
WORKDIR ${TOMCAT_BASE}
RUN ./rdpro-installer install-all

