# Docker SQL Server for Dev

This image allows you to quickly start a SQL Server 2017 server in Docker for the testing needs of development teams. It uses Google Cloud Storage to retrieve SQL files to create tables and databases.

## Quickstart

To start you're gonna need: 

- A Google Cloud project
- A Google Cloud service account key
- A GCS bucket
- Your .sql files

1) Create a file named `.env` containing the required env variables :

```bash
touch .env
```

| Variable Name | Description | Required | Default |
|---------------|-------------|----------|---------|
| MSSQLDEV_GOOGLE_PROJECT_NAME | The name (ID) of your GCP project | yes | |
| MSSQLDEV_GCP_SA_EMAIL | Google cloud service account e-mail | yes | |
| MSSQLDEV_GCP_SA_KEY_PATH | Path to the service account json key (mounted as volume or copied inside the container) | yes or default | /home/mssql/secrets |
| MSSQLDEV_BUCKET_NAME | Name of the bucket containing your .sql files | yes | |
| ACCEPT_EULA | Wether or not you accept MSSQL EULA | yes (Must be yes for the server to start) | |
| SA_PASSWORD | Password of the user SA of MSSQL Server | yes | |


Example of `.env` file :

```yaml
MSSQLDEV_GOOGLE_PROJECT_NAME=myproject
MSSQLDEV_GCP_SA_EMAIL=myserviceaccount@myproject.iam.gserviceaccount.com
MSSQLDEV_GCP_SA_KEY_PATH=/home/mssql/secrets

ACCEPT_EULA=Y
SA_PASSWORD=MyStrongPassword@
```

2) Make sure your designated bucket file tree is like :

```
- databases
-- my_db_1_.sql
- tables
-- my_table_1.sql
```

3) Build this image

```bash
docker build . -t navision-dev:local
```

4) And run it ...

```bash
docker run -d -v $(pwd)/secrets:/home/mssql/secrets -v mssql_for_dev_data:/var/opt/mssql \
--env-file=$(pwd)/.env \
 --name sql1 -p 1434:1433 \
 navision-dev:local
```

If you want to update your database, simply add the files in your bucket and run 

```bash
docker exec -it MY_CONTAINER_NAME /home/mssql/update_sql_from_gcs.sh
```

## Acknowledgements

This image is based on mcr.microsoft.com/mssql/server:2017-latest