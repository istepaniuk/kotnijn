# Kotlin + Maven + Docker + GraalVM experiment

This is just an experiment to explore the use of GraalVM to generate a fast-booting container.
It's a vanilla Kotlin application with a RabbitMQ client.

The multi-stage Dockerfile builds a Docker image containing the GraalVM "native-image" binary.


