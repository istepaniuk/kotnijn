FROM maven:3.8.4-openjdk-17-slim as maven-builder

RUN mkdir /build
WORKDIR /build

COPY pom.xml /build
RUN ["mvn", "verify", "clean"]

COPY src /build/src
RUN ["mvn", "package"]


FROM ghcr.io/graalvm/native-image:java17-21.3.0 AS native-image-builder

COPY --from=maven-builder /build/target/kotnijn-1.0-SNAPSHOT.jar /

RUN native-image --static -jar ./kotnijn-1.0-SNAPSHOT.jar -H:Name=kotnijn


FROM scratch

COPY --from=native-image-builder /kotnijn /

ENTRYPOINT ["/kotnijn"]
