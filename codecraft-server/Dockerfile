FROM eclipse-temurin:17-jre
WORKDIR /app
COPY target/codecraft-server-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]