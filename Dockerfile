FROM    ubuntu:quantal
MAINTAINER      kload "kload@kload.fr"

# prevent apt from starting postgres right after the installation
RUN     echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d

# Add PostgreSQL's repository. It contains the most recent stable release
# #     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update
# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.3
# #  There are some warnings (in red) that show up during the build. You can hide
# #  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get -y -q install python-software-properties software-properties-common
# RUN apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3
RUN     LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y -q --force-yes postgresql-9.3 postgresql-contrib-9.3

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean

# allow autostart again
RUN     rm /usr/sbin/policy-rc.d

ADD     . /usr/bin
RUN     chmod +x /usr/bin/start_pgsql.sh
RUN echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/9.3/main/pg_hba.conf
RUN sed -i -e"s/var\/lib/opt/g" /etc/postgresql/9.3/main/postgresql.conf
