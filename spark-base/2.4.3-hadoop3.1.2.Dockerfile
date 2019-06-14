FROM honomoa/hadoop-base:3.1.2

ENV ENABLE_INIT_DAEMON true
ENV INIT_DAEMON_BASE_URI http://identifier/init-daemon
ENV INIT_DAEMON_STEP spark_master_init

ENV SPARK_VERSION=2.4.3
ENV SPARK_CONF_DIR=/etc/spark
ENV SPARK_HOME /opt/spark
ENV SPARK_URL https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop.tgz
ENV PATH $SPARK_HOME/bin:$PATH

WORKDIR /opt

COPY wait-for-step.sh /
COPY execute-step.sh /
COPY finish-step.sh /

RUN chmod a+x /*.sh

RUN curl -fSL $SPARK_URL -o /tmp/spark.tgz \
      && tar -xvf /tmp/spark.tgz -C /opt/ \
      && mv /opt/spark-$SPARK_VERSION-bin-without-hadoop /opt/spark-$SPARK_VERSION \
      && ls -al \
      && rm /tmp/spark.tgz \
      && cd /

RUN ln -s /opt/spark-$SPARK_VERSION/conf $SPARK_CONF_DIR && \
    ln -s /opt/spark-$SPARK_VERSION $SPARK_HOME

RUN apt-get update && apt-get install -y python3 python3-setuptools python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV PYTHONHASHSEED 1

COPY hive-site.xml $SPARK_CONF_DIR
COPY spark-env.sh $SPARK_CONF_DIR

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
