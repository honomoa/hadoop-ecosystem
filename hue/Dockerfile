FROM ubuntu:16.04 as intermediate

RUN apt-get update -y \
    && apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update -y \
    && apt-get install -y \
      build-essential \
      libkrb5-dev \
      libmysqlclient-dev \
      libssl-dev \
      libsasl2-dev \
      libsasl2-modules-gssapi-mit \
      libsqlite3-dev \
      libtidy-0.99-0 \
      libxml2-dev \
      libxslt-dev \
      libffi-dev \
      libldap2-dev \
      libpq-dev \
      python-dev \
      python-pip \
      python-setuptools \
      libgmp3-dev \
      libz-dev \
      software-properties-common \
      git \
      sudo \
      maven \
      openjdk-8-jdk \
      nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install psycopg2-binary

WORKDIR  /ws

RUN git clone https://github.com/cloudera/hue.git --branch master \
    && cd hue \
    && make apps \
    && PREFIX=/usr/share make install

RUN ls -al /usr/share/hue
RUN ls -al /ws/hue

FROM ubuntu:16.04

RUN apt-get update -y \
    && apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash -

COPY --from=intermediate /usr/share/hue /usr/share/hue

RUN apt-get update -y \
    && apt-get install -y \
      openjdk-8-jre \
      nodejs \
      libsasl2-modules-gssapi-mit \
      libsnappy-dev \
      libtidy-0.99-0 \
      python-pip \
      libxslt1.1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install psycopg2-binary \
      python-snappy \
    && useradd -ms /bin/bash hue && chown -R hue /usr/share/hue

RUN rm -rf /usr/share/hue/desktop/conf/pseudo-distributed.ini*
COPY --from=intermediate /ws/hue/tools/docker/hue/startup.sh /usr/share/hue/startup.sh
COPY --from=intermediate /ws/hue/webpack-stats*.json /usr/share/hue/

WORKDIR  /usr/share/hue

EXPOSE 8888

CMD [ "./startup.sh" ]
