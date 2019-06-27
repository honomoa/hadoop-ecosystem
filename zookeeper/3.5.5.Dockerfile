FROM openjdk:8

HEALTHCHECK CMD echo stat | nc localhost 2181 || exit 1

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV ZOOKEEPER_USER=zookeeper
ENV ZOOKEEPER_VERSION=3.5.5
ENV ZOOKEEPER_CONF_DIR=/etc/zookeeper
ENV ZOOCFGDIR=/etc/zookeeper
ENV ZOOKEEPER_HOME=/opt/zookeeper
ENV ZOOKEEPER_URL=https://archive.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz
ENV PATH=$ZOOKEEPER_HOME/bin:$PATH

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends net-tools curl netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fSL https://archive.apache.org/dist/zookeeper/KEYS | gpg --import -

RUN set -x \
    && curl -fSL "$ZOOKEEPER_URL" -o /tmp/zookeeper.tar.gz \
    && curl -fSL "$ZOOKEEPER_URL.asc" -o /tmp/zookeeper.tar.gz.asc \
    && gpg --verify /tmp/zookeeper.tar.gz.asc \
    && tar -xvf /tmp/zookeeper.tar.gz -C /opt/ \
    && rm /tmp/zookeeper.tar.gz*

RUN ln -s /opt/apache-zookeeper-$ZOOKEEPER_VERSION-bin/conf $ZOOKEEPER_CONF_DIR && \
    ln -s /opt/apache-zookeeper-$ZOOKEEPER_VERSION-bin $ZOOKEEPER_HOME

RUN mkdir -p $ZOOKEEPER_HOME/data && \
    mkdir -p $ZOOKEEPER_HOME/logs
VOLUME $ZOOKEEPER_HOME/data $ZOOKEEPER_HOME/logs

EXPOSE 2181 2888 3888

ENV USER=root

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]
