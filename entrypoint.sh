#!/usr/bin/env bash

if [ -z "$MSSQLDEV_GOOGLE_PROJECT_NAME" ]
then
    echo "You must declare MSSQLDEV_GOOGLE_PROJECT_NAME"
    exit 1
fi

if [ -z "$MSSQLDEV_GCP_SA_EMAIL" ]
then
    echo "You must declare MSSQLDEV_GCP_SA_EMAIL"
    exit 1
fi


if [ -z "$MSSQLDEV_GCP_SA_KEY_PATH" ]
then
    MSSQLDEV_GCP_SA_KEY_PATH="/home/mssql/secrets/service-account.json"
fi

echo "Setting up google cloud with service account e-mail $MSSQLDEV_GCP_SA_EMAIL and key located at $MSSQLDEV_GCP_SA_KEY_PATH"

gcloud auth activate-service-account $MSSQLDEV_GCP_SA_EMAIL --key-file=$MSSQLDEV_GCP_SA_KEY_PATH
gcloud config set project $MSSQLDEV_GOOGLE_PROJECT_NAME

echo "To restore databases and tables for the first time, SQL Server is started with nohup and the PID is stored in save_pid.txt."

nohup /opt/mssql/bin/sqlservr >> /var/log/mssql/mssql.log 2>&1 &
echo $! > save_pid.txt
ln -sf /dev/stdout /var/log/mssql/mssql.log

echo "-- Waiting 20 sec for SQL Server to start --"
sleep 20

echo "Restoring databses and tables files"
/home/mssql/update_sql_from_gcs.sh

echo "Stopping MSSQL Server running via nohup"
kill -9 `cat save_pid.txt`
rm save_pid.txt

echo "Starting MSSQL Server as the main program for this container"
/opt/mssql/bin/sqlservr