#!/bin/bash

echo "Installing postgres-client..." 

apk update
apk add postgresql-client

echo "Installing postgres-client. Done" 

echo "Creating Harbor databases if they do not exist..."
psql -tc "SELECT 1 FROM pg_database WHERE datname = 'registry'" | grep -q 1 || psql -c "CREATE DATABASE registry"
psql -tc "SELECT 1 FROM pg_database WHERE datname = 'clair'" | grep -q 1 || psql -c "CREATE DATABASE clair"
psql -tc "SELECT 1 FROM pg_database WHERE datname = 'notary_server'" | grep -q 1 || psql -c "CREATE DATABASE notary_server"
psql -tc "SELECT 1 FROM pg_database WHERE datname = 'notary_signer'" | grep -q 1 || psql -c "CREATE DATABASE notary_signer"

echo "Creating Harbor databases. Done"

 while [ 0 = 0 ]; do
   sleep 1
 done;