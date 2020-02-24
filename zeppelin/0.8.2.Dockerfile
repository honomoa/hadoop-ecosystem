FROM honomoa/spark-base:2.4.3-hadoop3.1.2

HEALTHCHECK CMD echo stat | nc localhost 8080 || exit 1

ENV ZEPPELIN_USER=zeppelin
ENV ZEPPELIN_VERSION=0.8.2
ENV ZEPPELIN_CONF_DIR=/etc/zeppelin
ENV ZEPPELIN_HOME=/opt/zeppelin
ENV ZEPPELIN_URL=https://archive.apache.org/dist/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz
ENV PATH=$ZEPPELIN_HOME/bin:$PATH

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends net-tools curl netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fSL https://archive.apache.org/dist/zeppelin/KEYS | gpg --import -

RUN set -x \
    && curl -fSL "$ZEPPELIN_URL" -o /tmp/zeppelin.tar.gz \
    && curl -fSL "$ZEPPELIN_URL.asc" -o /tmp/zeppelin.tar.gz.asc \
    && gpg --verify /tmp/zeppelin.tar.gz.asc \
    && tar -xvf /tmp/zeppelin.tar.gz -C /opt/ \
    && mv /opt/zeppelin-${ZEPPELIN_VERSION}-bin-all /opt/zeppelin-${ZEPPELIN_VERSION} \
    && rm /tmp/zeppelin.tar.gz*

RUN ln -s /opt/zeppelin-$ZEPPELIN_VERSION/conf $ZEPPELIN_CONF_DIR && \
    ln -s /opt/zeppelin-$ZEPPELIN_VERSION $ZEPPELIN_HOME

COPY zeppelin-site.xml $ZEPPELIN_CONF_DIR

RUN mkdir -p $ZEPPELIN_HOME/data && \
    mkdir -p $ZEPPELIN_HOME/logs
VOLUME $ZEPPELIN_HOME/data $ZEPPELIN_HOME/logs

# Install R
RUN echo "deb http://cran.mtu.edu/bin/linux/debian stretch-cran35/" | tee -a /etc/apt/sources.list && \
    apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF' && \
    apt update && \
    apt install -y --allow-unauthenticated r-base r-base-dev && \
    apt clean

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR $ZEPPELIN_HOME
CMD ["bin/zeppelin.sh"]
