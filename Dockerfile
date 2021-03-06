FROM debian:jessie

RUN useradd -u 1100 postgres && useradd -u 1099 dummyuser

RUN apt-get -y update && \
apt-get -y install wget nano git postgresql && rm -rf /var/lib/apt/lists/*

RUN  mkdir /home/dbbackup && cp -r /var/lib/postgresql/9.4/main/* /home/dbbackup/

COPY check.gpr /check.gpr
COPY ./installjira /installjira
COPY ./dbconfig.xml /var/atlassian/jira-home/dbconfig.xml

RUN cd / && wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-7.5.0-x64.bin \
&& sha256sum -c check.gpr \
&& chmod a+x atlassian-jira-software-7.5.0-x64.bin \
&& cd / && ./atlassian-jira-software-7.5.0-x64.bin < ./installjira \
&& rm /atlassian-jira-software-7.5.0-x64.bin

VOLUME /var/lib/postgresql/9.4/main /var/atlassian/jira-app /var/atlassian/jira-home

EXPOSE 8080

COPY ./entrypoint.sh /entrypoint.sh
COPY ./createdb.sql /createdb.sql

ENTRYPOINT [ "/entrypoint.sh" ]
