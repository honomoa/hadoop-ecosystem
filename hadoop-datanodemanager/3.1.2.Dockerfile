FROM honomoa/hadoop-base:3.1.2

HEALTHCHECK CMD netstat -nl | egrep "8042|9864" > /dev/null; if [ 0 != $? ]; then exit 1; fi;

ENV HDFS_CONF_dfs_datanode_data_dir=file:///hadoop/dfs/data
RUN mkdir -p /hadoop/dfs/data
VOLUME /hadoop/dfs/data

# Install python3.7
RUN apt update && apt install -y python3 && \
    apt clean

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 9864 8042

CMD ["/run.sh"]
