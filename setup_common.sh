#!/usr/bin/env bash
set -e

make_user_superuser() {
    psql ${PSQL_ARGS} --dbname postgres -c "ALTER ROLE $1 WITH SUPERUSER;"
}

update_user_password() {
    if [ -n "$1" ]; then
        psql ${PSQL_ARGS} --dbname postgres -c "ALTER USER $2 WITH ENCRYPTED PASSWORD '$3'"
    fi
}

check_postgres_connection() {
    echo -e "Waiting for Postgres to be ready\c"
    until pg_isready -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -U ${POSTGRES_USER}${POSTGRES_USER_SUFFIX} >/dev/null; do echo -e ".\c"; sleep 1; done
    echo " OK"
    echo ""

    echo -e "Waiting for Postgres to accept queries\c"
    until psql ${PSQL_ARGS} --dbname=postgres -c "SELECT 1;" >/dev/null; do echo -e ".\c"; sleep 1; done
    echo " OK"
    echo ""
}

check_user_exists() {
    USERNAME=$1
    USER_EXISTS=$(psql ${PSQL_ARGS} --dbname=postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='${USERNAME}';")
    if [ "${USER_EXISTS}" -eq 1 ]; then
        echo "Already exists"
        return 0
    else
        return 1
    fi
}

check_db_exists() {
    DBNAME=$1
    DB_EXISTS=$(psql ${PSQL_ARGS} --dbname=postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${DBNAME}';")
    if [ "${DB_EXISTS}" -eq 1 ]; then
        echo "Already exists"
        return 0
    else
        return 1
    fi
}
