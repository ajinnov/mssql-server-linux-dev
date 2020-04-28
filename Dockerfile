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

# Create non-root user and update permissions
#
RUN useradd -M -s /bin/bash -u 10001 -g 0 mssql
RUN mkdir -p -m 770 /var/opt/mssql && chgrp -R 0 /var/opt/mssql
RUN mkdir -p -m 770 /home/mssql && chgrp -R 0 /home/mssql
RUN mkdir -p -m 770 /var/log/mssql && chgrp -R 0 /var/log/mssql
# Grant sql the permissions to connect to ports <1024 as a non-root user
#
RUN setcap 'cap_net_bind_service+ep' /opt/mssql/bin/sqlservr

# Allow dumps from the non-root process
# 
RUN setcap 'cap_sys_ptrace+ep' /opt/mssql/bin/paldumper
RUN setcap 'cap_sys_ptrace+ep' /usr/bin/gdb

# Add an ldconfig file because setcap causes the os to remove LD_LIBRARY_PATH
# and other env variables that control dynamic linking
#
RUN mkdir -p /etc/ld.so.conf.d && touch /etc/ld.so.conf.d/mssql.conf
RUN echo -e "# mssql libs\n/opt/mssql/lib" >> /etc/ld.so.conf.d/mssql.conf
RUN ldconfig

USER mssql
COPY entrypoint.sh /home/mssql/entrypoint.sh
ENTRYPOINT ["/home/mssql/entrypoint.sh"]