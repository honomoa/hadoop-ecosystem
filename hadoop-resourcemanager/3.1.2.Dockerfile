FROM honomoa/hadoop-base:3.1.2

HEALTHCHECK CMD curl -f http://localhost:8088/ || exit 1

ENV YARN_CONF_yarn_resourcemanager_fs_state___store_uri=/hadoop/yarn/system/rmstore
ENV YARN_CONF_yarn_resourcemanager_leveldb___state___store_path=/hadoop/yarn/system/rmstore
RUN mkdir -p /hadoop/yarn/system/rmstore
VOLUME /hadoop/yarn/system/rmstore

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8088

CMD ["/run.sh"]
