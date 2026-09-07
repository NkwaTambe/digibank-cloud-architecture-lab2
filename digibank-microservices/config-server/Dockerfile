FROM eclipse-temurin:17-jre
WORKDIR /app
COPY config-server/target/config-server-1.0.0.jar app.jar
COPY config-repo /app/config-repo
EXPOSE 8888
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
