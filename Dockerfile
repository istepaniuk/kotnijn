# First build stage: Java/Kotiln compilation with Maven
FROM maven:3.8.4-openjdk-17-slim as maven-builder

RUN mkdir /build
WORKDIR /build

COPY pom.xml /build
RUN ["mvn", "verify", "clean"]

COPY src /build/src
RUN ["mvn", "package"]


# Second build stage: Converting the generated .jar into a GraalVM native-image
FROM ghcr.io/graalvm/native-image:ol8-java17-22.0.0.2 AS graalvm-builder

COPY --from=maven-builder /build/target/kotnijn-1.0-SNAPSHOT-jar-with-dependencies.jar /

RUN native-image -jar ./kotnijn-1.0-SNAPSHOT-jar-with-dependencies.jar \
    kotnijn \
    --install-exit-handlers \
    --no-fallback

# Third build stage, use larks/dockerize scripts to indentify and bundle dynamic dependencies
FROM istepaniuk/larks-dockerize-docker AS dockerize-builder

COPY --from=graalvm-builder /kotnijn /

RUN mkdir /build && dockerize --no-build --output-dir /build /kotnijn


FROM scratch

COPY --from=dockerize-builder /build /

ENTRYPOINT ["/kotnijn"]
