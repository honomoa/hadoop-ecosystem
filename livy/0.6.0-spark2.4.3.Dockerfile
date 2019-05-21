FROM honomoa/spark-base:2.4.3-hadoop3.1.2

HEALTHCHECK CMD curl -f http://localhost:8998/ || exit 1

ENV LIVY_VERSION=0.6.0-incubating
ENV LIVY_CONF_DIR=/etc/livy
ENV LIVY_HOME /opt/livy
ENV LIVY_URL https://archive.apache.org/dist/incubator/livy/$LIVY_VERSION/apache-livy-$LIVY_VERSION-bin.zip
ENV PATH $LIVY_HOME/bin:$PATH

WORKDIR /opt

RUN curl -fSL $LIVY_URL -o /tmp/livy.zip \
      && unzip /tmp/livy.zip \
      && mv /opt/apache-livy-$LIVY_VERSION-bin /opt/livy-$LIVY_VERSION \
      && ls -al \
      && rm /tmp/livy.zip \
      && cd /

RUN ln -s /opt/livy-$LIVY_VERSION/conf $LIVY_CONF_DIR && \
    ln -s /opt/livy-$LIVY_VERSION $LIVY_HOME

VOLUME $LIVY_CONF_DIR/livy.conf
VOLUME $LIVY_CONF_DIR/livy-client.conf

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8998

CMD ["/run.sh"]
