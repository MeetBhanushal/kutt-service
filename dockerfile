FROM kutt/kutt


RUN apk add --no-cache bash postgresql postgresql-contrib redis su-exec wget


RUN mkdir -p /run/postgresql /run/redis /data/postgres /data/redis && \
    chown -R postgres:postgres /run/postgresql /data/postgres && \
    chown -R redis:redis /run/redis /data/redis

RUN wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && chmod +x wait-for-it.sh

# Initialize postgres database
USER postgres
RUN initdb -D /data/postgres && \
    echo "host all all 0.0.0.0/0 md5" >> /data/postgres/pg_hba.conf && \
    echo "listen_addresses='*'" >> /data/postgres/postgresql.conf

USER root

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV DB_HOST=localhost \
    DB_NAME=kutt \
    DB_USER=user \
    DB_PASSWORD=pass \
    REDIS_HOST=localhost \
    PORT=3000


EXPOSE 3000

CMD ["/start.sh"]