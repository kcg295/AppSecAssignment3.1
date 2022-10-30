FROM mysql:latest

RUN mkdir /data
COPY ./products.csv /data/products.csv
COPY ./users.csv /data/users.csv
COPY ./setup.sql /docker-entrypoint-initdb.d/setup.sql

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld", "--secure-file-priv=/data"]
#CMD ["--secure-file-priv=/"]
