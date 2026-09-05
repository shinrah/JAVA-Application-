FROM tomcat:9-jdk8-alpine

RUN rm -rf /usr/local/tomcat/webapps/*

COPY webapp/target/webapp-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
