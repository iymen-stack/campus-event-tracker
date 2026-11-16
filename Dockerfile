# Adapted from CSC443's two-stage Java web app exercise.
# Build context is the repository root, so both backend/ and frontend/ are available.
FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace

COPY backend/.mvn/ .mvn/
COPY backend/mvnw backend/pom.xml ./
# Windows checkouts sometimes give the Maven wrapper CRLF line endings.
RUN sed -i 's/\r$//' mvnw && chmod +x mvnw

COPY backend/src/ src/
# Package the current HTML/CSS/JavaScript within Spring Boot's static resources.
COPY frontend/ src/main/resources/static/
RUN ./mvnw -B -DskipTests package

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /workspace/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
