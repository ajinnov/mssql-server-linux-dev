FROM mcr.microsoft.com/mssql/server:2017-latest

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && apt-get install -y \
  apt-transport-https \
  software-properties-common \
  ca-certificates \
  curl \
  wget \
  gnupg 

# Google cloud SDK to use gsutils
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y \ 
  google-cloud-sdk


RUN mkdir /home/mssql
RUN mkdir /var/log/mssql

ADD sql /home/mssql/sql
COPY entrypoint.sh /home/mssql/entrypoint.sh

COPY update_sql_from_gcs.sh /home/mssql/update_sql_from_gcs.sh

CMD ["/home/mssql/entrypoint.sh"]