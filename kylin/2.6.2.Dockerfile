FROM honomoa/hbase-base:2.1.4-hadoop3.1.2

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

ENV HIVE_VERSION 3.1.1
ENV HIVE_CONF_DIR /etc/hive
ENV HIVE_HOME /opt/hive
ENV HIVE_URL https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
ENV PATH $HIVE_HOME/bin:$PATH

RUN curl -fSL $HIVE_URL -o /tmp/hive.tar.gz && \
	tar -xvf /tmp/hive.tar.gz -C /opt/ && \
	mv /opt/apache-hive-$HIVE_VERSION-bin /opt/hive-$HIVE_VERSION && \
	ls -al && \
	rm /tmp/hive.tar.gz

RUN ln -s /opt/hive-$HIVE_VERSION/conf $HIVE_CONF_DIR && \
    ln -s /opt/hive-$HIVE_VERSION $HIVE_HOME

ENV SPARK_VERSION=2.4.3
ENV SPARK_CONF_DIR=/etc/spark
ENV SPARK_HOME /opt/spark
ENV SPARK_URL https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop.tgz
ENV PATH $SPARK_HOME/bin:$PATH

RUN curl -fSL $SPARK_URL -o /tmp/spark.tgz \
      && tar -xvf /tmp/spark.tgz -C /opt/ \
      && mv /opt/spark-$SPARK_VERSION-bin-without-hadoop /opt/spark-$SPARK_VERSION \
      && ls -al \
      && rm /tmp/spark.tgz \
      && cd /

RUN ln -s /opt/spark-$SPARK_VERSION/conf $SPARK_CONF_DIR && \
    ln -s /opt/spark-$SPARK_VERSION $SPARK_HOME && \
    ln -s /opt/spark-$SPARK_VERSION/jars /opt/spark-$SPARK_VERSION/jars/lib

ADD conf/hive-site.xml $HIVE_CONF_DIR
ADD conf/tomcat_server.xml $KYLIN_HOME/tomcat/conf/server.xml
RUN rm $KYLIN_HOME/tomcat/conf/server.xml.init

ADD entrypoint.sh /entrypoint.sh
ADD run.sh /run.sh
RUN chmod a+x /entrypoint.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD /run.sh
