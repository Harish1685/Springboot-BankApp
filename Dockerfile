# ------- Stage 1 ------------

# Importing a maven image for the builder
FROM maven:3.9.9-eclipse-temurin-17 as builder

# Setting up the working directory to /src
WORKDIR /src

# Copying the source code from local to container
COPY . /src

# Building the application and skipping the tests
RUN mvn clean package -DskipTests=true

# --------- Stage 2 -----------


# Importing an alpine image for deployer
FROM eclipse-temurin:17-jdk-alpine as deployer

# copying the jar files from the builder
COPY --from=builder /src/target/*.jar /src/target/bankapp.jar

# Exposing the port to 8080
EXPOSE 8080

# Starting the application
ENTRYPOINT [ "java" , "-jar" , "/src/target/bankapp.jar" ]