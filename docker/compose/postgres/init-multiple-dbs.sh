#!/bin/bash
# Creates multiple PostgreSQL databases from the POSTGRES_MULTIPLE_DATABASES env var.
# Usage: set POSTGRES_MULTIPLE_DATABASES=db1,db2,db3
set -e

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "Creating databases: $POSTGRES_MULTIPLE_DATABASES"
    for db in $(echo "$POSTGRES_MULTIPLE_DATABASES" | tr ',' ' '); do
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
            SELECT 'CREATE DATABASE $db'
            WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\gexec
EOSQL
        echo "Database '$db' ready."
    done
fi
