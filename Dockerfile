FROM openjdk:11-jre
ARG JAR_FILE=target/*.jar
EXPOSE 8761
COPY build/libs/mystro-backend-discovery-*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
