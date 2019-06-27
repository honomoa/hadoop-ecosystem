FROM honomoa/hive-base:3.1.1-spark2.4.3

ENV HBASE_VERSION=2.1.5
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

ENV KYLIN_VERSION=2.6.2
ENV KYLIN_CONF_DIR=/etc/kylin
ENV KYLIN_HOME /opt/kylin
ENV KYLIN_URL https://archive.apache.org/dist/kylin/apache-kylin-$KYLIN_VERSION/apache-kylin-$KYLIN_VERSION-bin-hadoop3.tar.gz   
ENV PATH $HIVE_HOME/bin:$KYLIN_HOME/bin:$PATH

RUN curl -fSL https://archive.apache.org/dist/kylin/KEYS | gpg --import -

RUN set -x \
    && curl -fSL "$KYLIN_URL" -o /tmp/kylin.tar.gz \
    && curl -fSL "$KYLIN_URL.asc" -o /tmp/kylin.tar.gz.asc \
    && gpg --verify /tmp/kylin.tar.gz.asc \
    && tar -xvf /tmp/kylin.tar.gz -C /opt/ \
    && rm /tmp/kylin.tar.gz*

RUN ln -s /opt/apache-kylin-$KYLIN_VERSION-bin-hadoop3/conf $KYLIN_CONF_DIR && \
    ln -s /opt/apache-kylin-$KYLIN_VERSION-bin-hadoop3 $KYLIN_HOME

RUN ln -s /opt/spark-$SPARK_VERSION/jars /opt/spark-$SPARK_VERSION/jars/lib

ADD conf/tomcat_server.xml $KYLIN_HOME/tomcat/conf/server.xml
RUN rm $KYLIN_HOME/tomcat/conf/server.xml.init

ADD entrypoint.sh /entrypoint.sh
ADD run.sh /run.sh
RUN chmod a+x /entrypoint.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD /run.sh
