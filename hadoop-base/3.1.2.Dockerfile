FROM openjdk:8

ENV HADOOP_VERSION 3.1.2
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_URL https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV PATH $HADOOP_HOME/bin:$PATH

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends net-tools curl netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fSL https://archive.apache.org/dist/hadoop/core/KEYS | gpg --import -

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc \
    && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
    && rm /tmp/hadoop.tar.gz*

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop $HADOOP_CONF_DIR && \
    ln -s /opt/hadoop-$HADOOP_VERSION $HADOOP_HOME && \
    ln -s /opt/hadoop-$HADOOP_VERSION/share/hadoop/tools/lib/aws-java-sdk-*.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop-$HADOOP_VERSION/share/hadoop/tools/lib/hadoop-aws-*.jar $HADOOP_HOME/share/hadoop/common/lib/

RUN mkdir -p $HADOOP_HOME/logs
VOLUME $HADOOP_HOME/logs

ENV MULTIHOMED_NETWORK=1

ENV USER=root

RUN apt-get update && apt-get install -y libsnappy-dev && \
    ln -s /usr/lib/x86_64-linux-gnu/libsnappy.so $HADOOP_HOME/lib/native && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
