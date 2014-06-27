#!/bin/bash

service postgresql start 2>&1 > /dev/null

# Check if we can login as the postgres user without 
# Run psql in the background
psql postgres -tAc "SELECT 1;" &
# Grab the PID
PID=$!
# Wait for the command to finish
sleep 1
# Try to kill psql
kill $PID
# If psql asked for a password, the PID would still exist and kill would kill
# it and exit normally with status 0
# If psql ran the command successfully (and didn't require a login) then kill
# would not be able to kill the PID and would exit with exit status 1
NO_PSQL_PASSWORD=$?

# If psql doesn't require a password, then set one and create the database
if [[ $NO_PSQL_PASSWORD ]]; then
	echo "Creating user"
	su postgres sh -c "/usr/lib/postgresql/9.3/bin/postgres --single -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf" <<< "CREATE USER root WITH PASSWORD '$1';"
	echo "Creating database"
	su postgres sh -c "/usr/lib/postgresql/9.3/bin/postgres --single -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf" <<< "CREATE DATABASE db ENCODING 'UTF8' TEMPLATE template0;"
	echo "Granting CONNECT permissions"
	su postgres sh -c "/usr/lib/postgresql/9.3/bin/postgres --single -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf" <<< "GRANT CONNECT, TEMPORARY ON DATABASE db TO root;"
	echo "Granting SELECT, INSERT, UPDATE, DELETE, REFERENCES, TRIGGER, and TRUNCATE permissions"
	su postgres sh -c "/usr/lib/postgresql/9.3/bin/postgres --single -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf" <<< "GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES, TRIGGER, TRUNCATE ON ALL TABLES IN SCHEMA public TO root;"
fi

service postgresql stop 2>&1 > /dev/null

# Start PostgreSQL
sudo -u postgres /usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf
