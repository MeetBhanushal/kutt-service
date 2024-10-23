#!/bin/bash

su-exec redis redis-server --daemonize yes --dir /data/redis

if [ "$DB_HOST" = "localhost" ] || [ -z "$DB_HOST" ]; then
    echo "Using internal PostgreSQL database..."
    
    su-exec postgres postgres -D /data/postgres &
    
    ./wait-for-it.sh localhost:5432 -t 30
    
    if ! su-exec postgres psql -lqt | cut -d \| -f 1 | grep -qw "${DB_NAME}"; then
        su-exec postgres createuser -s "${DB_USER}"
        su-exec postgres createdb -O "${DB_USER}" "${DB_NAME}"
        su-exec postgres psql -c "ALTER USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';"
    fi
else
    echo "Using external PostgreSQL database at ${DB_HOST}..."
    ./wait-for-it.sh ${DB_HOST}:${DB_PORT:-5432} -t 30
fi

if [ ! -z "$ENV_FILE" ]; then
    wget -O .env "$ENV_FILE"
fi

exec npm start