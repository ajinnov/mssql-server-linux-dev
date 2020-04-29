#!/usr/bin/env bash


if [ -z "$MSSQLDEV_BUCKET_NAME" ]
then
    echo "MSSQLDEV_BUCKET_NAME must be set"
    exit 1
fi

gsutil -m rsync -r gs://$MSSQLDEV_BUCKET_NAME /home/mssql/sql

for sqlfile in /home/mssql/sql/databases/*
do
    echo "Playing $sqlfile"
    /opt/mssql-tools/bin/sqlcmd -S tcp:127.0.0.1,1433 -U sa -P $SA_PASSWORD -i $sqlfile -o /home/mssql/${sqlfile##*/}
done

for sqlfile in /home/mssql/sql/tables/*
do
    echo "Playing $sqlfile"
    /opt/mssql-tools/bin/sqlcmd -S tcp:127.0.0.1,1433 -U sa -P $SA_PASSWORD -i $sqlfile -o /home/mssql/${sqlfile##*/}
done