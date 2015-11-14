FROM mysql:5.5

ENV MYSQL_DATABASE go-service-basic

ENV MYSQL_ROOT_PASSWORD whatever

COPY ./docker/testdb/createdb.sql /docker-entrypoint-initdb.d/