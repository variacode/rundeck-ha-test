FROM ubuntu:16.04

# Change APT repo
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
ENV USER rundeck
ENV HOME /home/rundeck

#create rundeck user
RUN adduser --shell /bin/bash --home ${HOME} --gecos "" --disabled-password ${USER} && passwd -d ${USER} && addgroup ${USER} sudo

COPY rdpro-installer ${HOME}/rdpro-installer
COPY install-and-run.sh ${HOME}/install-and-run

RUN chown -R ${USER}:${USER} ${HOME}
RUN chmod +x ${HOME}/install-and-run

USER ${USER}
WORKDIR ${HOME}
VOLUME ${HOME}

CMD ${HOME}/install-and-run
