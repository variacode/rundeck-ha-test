FROM ubuntu:16.04

#general package configuration
RUN apt-get -y update && apt-get -y dist-upgrade && apt-get -y autoremove
RUN apt-get -y install sudo unzip curl xmlstarlet git netcat-traditional software-properties-common debconf-utils

# Install Oracle JVM
RUN add-apt-repository -y ppa:webupd8team/java && apt-get update
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && apt-get install -y oracle-java8-installer

# groupadd y useradd valen callampa. no usar.
#RUN groupadd -r rundeck && useradd -m -g rundeck rundeck

#create rundeck user
RUN adduser --shell /bin/bash --home /home/rundeck --gecos "" --disabled-password rundeck
RUN passwd -d rundeck
RUN addgroup rundeck sudo

USER rundeck
WORKDIR /home/rundeck

#COPY ./rundeckpro-installer /home/rundeck/rundeckpro-installer
#WORKDIR /home/rundeck/rundeckpro-installer
#RUN ./build.sh --notests --bundle
