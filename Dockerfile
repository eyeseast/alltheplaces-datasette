FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    SQLITE_VERSION=3390400 \
    LD_PRELOAD=/usr/local/lib/libsqlite3.so

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
    python3-dev python3-pip cmake build-essential tcl wget


RUN wget -O sqlite.tar.gz https://sqlite.org/2022/sqlite-autoconf-${SQLITE_VERSION}.tar.gz && \
    tar -xzvf sqlite.tar.gz && \
    (cd sqlite-autoconf-${SQLITE_VERSION} && ./configure && make && make install)

RUN apt-get install -y libsqlite3-mod-spatialite && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
ADD . /app

RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    rm -rf /root/.cache/pip

EXPOSE 8001

CMD [ "./start.sh" ]