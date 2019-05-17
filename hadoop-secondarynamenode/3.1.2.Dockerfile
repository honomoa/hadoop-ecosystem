FROM honomoa/hadoop-base:3.1.2

HEALTHCHECK CMD curl -f http://localhost:9868/ || exit 1

ENV HDFS_CONF_dfs_namenode_checkpoint_dir=file:///hadoop/dfs/namesecondary
RUN mkdir -p /hadoop/dfs/namesecondary
VOLUME /hadoop/dfs/namesecondary

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 9868

CMD ["/run.sh"]
