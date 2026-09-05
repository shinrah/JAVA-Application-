FROM alpine:3.20

COPY webapp/target/webapp-1.0-SNAPSHOT.war /app/webapp.war

CMD ["sh", "-c", "echo 'Docker image built successfully'; sleep 3600"]
