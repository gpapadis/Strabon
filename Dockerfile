FROM mdillon/postgis
MAINTAINER George Papadakis <gpapadis@di.uoa.gr>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.55

RUN apt-get update && apt-get install -y \
	default-jdk \
	maven \
	mercurial \
	wget \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

# INSTALL TOMCAT
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat

RUN hg clone 'http://hg.strabon.di.uoa.gr/Strabon/' && \
    cd Strabon && \
    mvn clean package

RUN mkdir /tomcat$TOMCAT_VERSION/webapps/strabon && \
    unzip /Strabon/endpoint/target/strabon-endpoint-*.war \
		-d /tomcat$TOMCAT_VERSION/webapps/strabon && \
    rm -Rf /Strabon

RUN sed -i 's/localhost/postgis/' /tomcat$TOMCAT_VERSION/webapps/strabon/WEB-INF/connection.properties

# Java options
ENV JAVA_OPTS -server -Xms2048m -Xmx2048m -XX:NewSize=512m \
              -XX:MaxNewSize=512m -XX:PermSize=2048m \
              -XX:MaxPermSize=2048m -Dfile.encoding=UTF8

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

EXPOSE 8080
CMD ["/run.sh"]
