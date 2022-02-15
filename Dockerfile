FROM maven:3.8.4-openjdk-17-slim as maven-builder

RUN mkdir /build
WORKDIR /build

COPY pom.xml /build
RUN ["mvn", "verify", "clean"]

COPY src /build/src
RUN ["mvn", "package"]


FROM ghcr.io/graalvm/native-image:ol8-java17-22.0.0.2 AS native-image-builder

COPY --from=maven-builder /build/target/kotnijn-1.0-SNAPSHOT-jar-with-dependencies.jar /

RUN native-image --no-fallback --static -jar ./kotnijn-1.0-SNAPSHOT-jar-with-dependencies.jar \
    -H:Name=kotnijn \
    -H:+ReportUnsupportedElementsAtRuntime


FROM scratch

COPY --from=native-image-builder /kotnijn /

ENTRYPOINT ["/kotnijn"]
