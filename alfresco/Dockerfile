# Dockerfile to build container based on CentOS 7 containing Alfresco 201605

FROM centos:7
MAINTAINER Tamer Embaby <tamer@embaby.com>
LABEL Description="Docker image (CentOS 7) for Alfresco 201605"

ENV ALFRESCO_HOME /opt/alfresco
ENV ALFRESCO_USER alfresco

# User and permissions.  The funny thing is, useradd has to come before USER.
RUN groupadd -g 888 alfresco && useradd -d /opt/alfresco -u 888 -g alfresco alfresco
RUN yum -y install ImageMagick fontconfig libSM libICE libXrender libXext \
	cups-libs libreoffice

# Copy entry point to root filesystem
COPY ./alfresco-entrypoint.sh /

# From now on act only as user alfresco
USER ${ALFRESCO_USER}

#VOLUME ${ALFRESCO_HOME}

ENTRYPOINT [ "/alfresco-entrypoint.sh" ]

CMD ["/opt/alfresco/tomcat/bin/catalina.sh", "run"]
