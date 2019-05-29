FROM honomoa/hadoop-base:3.1.2

ENV HBASE_VERSION=2.1.4
ENV HBASE_CONF_DIR=/etc/hbase
ENV HBASE_HOME /opt/hbase
ENV HBASE_URL https://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz
ENV HBASE_CLASSPATH $HBASE_HOME/lib/*
ENV PATH $HBASE_HOME/bin:$PATH

RUN curl -fSL https://archive.apache.org/dist/hbase/KEYS | gpg --import -

RUN set -x \
    && curl -fSL "$HBASE_URL" -o /tmp/hbase.tar.gz \
    && curl -fSL "$HBASE_URL.asc" -o /tmp/hbase.tar.gz.asc \
    && gpg --verify /tmp/hbase.tar.gz.asc \
    && tar -xvf /tmp/hbase.tar.gz -C /opt/ \
    && rm /tmp/hbase.tar.gz*

RUN ln -s /opt/hbase-$HBASE_VERSION/conf $HBASE_CONF_DIR && \
    ln -s /opt/hbase-$HBASE_VERSION $HBASE_HOME
RUN curl -fSL http://central.maven.org/maven2/org/apache/htrace/htrace-core/3.1.0-incubating/htrace-core-3.1.0-incubating.jar -o $HBASE_HOME/lib/htrace-core-3.1.0-incubating.jar

ENV USER=root

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
