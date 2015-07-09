FROM mdillon/postgis
MAINTAINER George Papadakis <gpapadis@di.uoa.gr>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TOMCAT_VERSION 7

RUN apt-get update && apt-get install -y \
	default-jdk \
	maven\
	mercurial \
	tomcat$TOMCAT_VERSION \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

RUN hg clone 'http://hg.strabon.di.uoa.gr/Strabon/' && \
    cd Strabon && \
    mvn clean package

RUN mkdir /var/lib/tomcat$TOMCAT_VERSION/webapps/strabon && \
    unzip /Strabon/endpoint/target/strabon-endpoint-*.war \
		-d /var/lib/tomcat$TOMCAT_VERSION/webapps/strabon && \
    rm -Rf /Strabon

RUN sed -i 's/localhost/postgis/' /var/lib/tomcat$TOMCAT_VERSION/webapps/strabon/WEB-INF/connection.properties

# Java options
ENV JAVA_OPTS -server -Xms2048m -Xmx2048m -XX:NewSize=512m \
              -XX:MaxNewSize=512m -XX:PermSize=2048m \
              -XX:MaxPermSize=2048m -Dfile.encoding=UTF8

# Tomcat ports
EXPOSE 8080 8009

# Default command to run when starting the container
ENTRYPOINT [ "/usr/share/tomcat"$TOMCAT_VERSION"/bin/catalina.sh", "run"]
