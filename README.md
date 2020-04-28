# Navision Dev in Docker

SQL Server 2017 with Navision tables in a Docker container.

```bash
docker build . -t navision-dev:local
docker run --rm -it -v $(pwd)/secrets:/home/mssql/secrets \
 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=MyStrongPassword@" --cap-add SYS_PTRACE --name sql1 -p 1433:1433 \
 navision-dev:local
```