#!/usr/bin/env bash
gcloud auth activate-service-account $SA_EMAIL --key-file=/home/mssql/secrets/service-account.json
gcloud config set project roland-coiffe
nohup /opt/mssql/bin/sqlservr >> /var/log/mssql/mssql.log &
bash