FROM honomoa/hadoop-base:3.1.2

HEALTHCHECK CMD curl -f http://localhost:8480/ || exit 1

ENV HDFS_CONF_dfs_journalnode_edits_dir=/hadoop/dfs/journalnode
RUN mkdir -p /hadoop/dfs/journalnode
VOLUME /hadoop/dfs/journalnode

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8480

CMD ["/run.sh"]
