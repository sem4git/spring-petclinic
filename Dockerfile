FROM openjdk:oraclelinux8
COPY ./target/spring-petclinic-*-SNAPSHOT.jar ./spring-petclinic.jar
EXPOSE 8080
CMD ["java", "-jar", "spring-petclinic.jar"]
