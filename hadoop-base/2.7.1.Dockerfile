FROM openjdk:8

ENV HADOOP_VERSION 2.7.1
ENV HADOOP_URL https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop

ENV DEBIAN_FRONTEND=noninteractive
ENV MULTIHOMED_NETWORK=1
ENV PATH $HADOOP_PREFIX/bin/:$PATH

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends net-tools curl libsnappy-dev && \
    apt-get clean

RUN set -x && \
    curl -sSL https://archive.apache.org/dist/hadoop/common/KEYS | gpg --import - && \
    curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz && \
    curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc && \
    gpg --verify /tmp/hadoop.tar.gz.asc && \
    tar -xvf /tmp/hadoop.tar.gz -C /opt/ && \
    rm /tmp/hadoop.tar.gz*
    
RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop && \
    cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml && \
    mkdir /opt/hadoop-$HADOOP_VERSION/logs && \
    mkdir /hadoop-data && \
    ln -s /usr/lib/x86_64-linux-gnu/libsnappy.so /opt/hadoop-$HADOOP_VERSION/lib/native

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENV USER=root

ENTRYPOINT ["/entrypoint.sh"]
