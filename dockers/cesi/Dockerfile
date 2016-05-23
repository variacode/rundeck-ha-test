FROM ubuntu:16.04

## http://stackoverflow.com/questions/20635472/using-the-run-instruction-in-a-dockerfile-with-source-does-not-work
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get -yqq update && apt-get install -yqq sqlite3 python python-flask git
RUN git clone https://github.com/GulsahKose/cesi /cesi

WORKDIR /cesi
RUN sqlite3 userinfo.db < userinfo.sql
COPY cesi.conf /etc/cesi.conf

WORKDIR /cesi/cesi
CMD python web.py
EXPOSE 5000
