FROM honomoa/spark-base:2.4.3-hadoop3.1.2

ENV HIVE_VERSION 3.1.1
ENV HIVE_CONF_DIR /etc/hive
ENV HIVE_HOME /opt/hive
ENV HIVE_URL https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
ENV JDBC_URL https://jdbc.postgresql.org/download/postgresql-42.2.4.jar
ENV PATH $HIVE_HOME/bin:$PATH

WORKDIR /opt

#Install Hive and PostgreSQL JDBC
RUN curl -fSL $HIVE_URL -o /tmp/hive.tar.gz && \
	tar -xvf /tmp/hive.tar.gz -C /opt/ && \
	mv /opt/apache-hive-$HIVE_VERSION-bin /opt/hive-$HIVE_VERSION && \
	ls -al && \
	curl -fSL $JDBC_URL -o /opt/hive-$HIVE_VERSION/lib/postgresql-jdbc.jar && \
	rm /tmp/hive.tar.gz

RUN ln -s /opt/hive-$HIVE_VERSION/conf $HIVE_CONF_DIR && \
    ln -s /opt/hive-$HIVE_VERSION $HIVE_HOME
RUN ln -s $SPARK_HOME/jars/jackson-module-paranamer-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/jackson-module-scala_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/jersey-container-servlet-core-2.28.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/json4s-ast_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/json4s-core_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/json4s-jackson_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/kryo-shaded-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/minlog-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/scala-library-2.11.*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/scala-xml_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/spark-core_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/spark-launcher_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/spark-network-common_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/spark-network-shuffle_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/spark-unsafe_2.11-*.jar $HIVE_HOME/lib && \
		ln -s $SPARK_HOME/jars/xbean-asm5-shaded-*.jar $HIVE_HOME/lib

#Spark should be compiled with Hive to be able to use it
#hive-site.xml should be copied to $SPARK_HOME/conf folder

#Custom configuration goes here
ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
