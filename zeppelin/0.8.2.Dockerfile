FROM honomoa/spark-base:2.4.3-hadoop3.1.2

HEALTHCHECK CMD echo stat | nc localhost 8080 || exit 1

ENV ZEPPELIN_USER=zeppelin
ENV ZEPPELIN_VERSION=0.8.2
ENV ZEPPELIN_CONF_DIR=/etc/zeppelin
ENV ZOOCFGDIR=/etc/zeppelin
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
    && rm /tmp/zeppelin.tar.gz*

RUN ln -s /opt/zeppelin-$ZEPPELIN_VERSION/conf $ZEPPELIN_CONF_DIR && \
    ln -s /opt/zeppelin-$ZEPPELIN_VERSION $ZEPPELIN_HOME

RUN mkdir -p $ZEPPELIN_HOME/data && \
    mkdir -p $ZEPPELIN_HOME/logs
VOLUME $ZEPPELIN_HOME/data $ZEPPELIN_HOME/logs

EXPOSE 8080

ENV USER=root

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR $ZEPPELIN_HOME
CMD ["bin/zeppelin.sh"]
