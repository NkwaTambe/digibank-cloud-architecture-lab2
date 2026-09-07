FROM eclipse-temurin:17-jre
WORKDIR /app
COPY transaction-service/target/transaction-service-1.0.0.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
