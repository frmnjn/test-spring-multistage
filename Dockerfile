FROM openjdk:8-jdk-alpine as build

WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY start.sh .

RUN chmod +x ./mvnw
RUN ./mvnw dependency:go-offline -B

COPY src src

RUN ./mvnw package -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM envoyproxy/envoy-alpine:v1.14.1 as final
EXPOSE 8080

RUN apk update && apk --no-cache add openjdk8 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community && rm -rf /var/lib/apt/lists/*
ARG DEPENDENCY=/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
COPY start.sh .

RUN chmod u+x ./start.sh
ENTRYPOINT ./start.sh

# Fire up our Spring Boot app by default
# ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -Duser.timezone=Indonesia/Jakarta -jar /app.jar --spring.config.location=/data/application.yml" ]