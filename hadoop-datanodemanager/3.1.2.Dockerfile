FROM honomoa/hadoop-base:3.1.2

HEALTHCHECK CMD netstat -nl | egrep "8042|9864" > /dev/null; if [ 0 != $? ]; then exit 1; fi;

ENV PYTHON_URL=https://www.python.org/ftp/python/3.7.6/Python-3.7.6.tar.xz
ENV HDFS_CONF_dfs_datanode_data_dir=file:///hadoop/dfs/data
RUN mkdir -p /hadoop/dfs/data
VOLUME /hadoop/dfs/data

# Install python3.7
RUN apt update && apt install --no-install-recommends -y \
      build-essential \
      zlib1g-dev \
      libncurses5-dev \
      libgdbm-dev \
      libnss3-dev \
      libssl-dev \
      libreadline-dev \
      libffi-dev && \
    curl -fSL "$PYTHON_URL" -o /tmp/Python-3.7.6.tar.xz && \
    cd /tmp && \
    tar -xf Python-3.7.6.tar.xz && \
    cd /tmp/Python-3.7.6 && \
    ./configure --enable-optimizations && \
    make -j8 && \
    make altinstall && \
    ln -sf /usr/local/bin/python3.7 /usr/bin/python && \
    ln -sf /usr/local/bin/python3.7 /usr/bin/python3 && \
    apt remove -y \
      build-essential \
      zlib1g-dev \
      libncurses5-dev \
      libgdbm-dev \
      libnss3-dev \
      libssl-dev \
      libreadline-dev \
      libffi-dev && \
    apt clean && \
    rm -r /tmp/Python*

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 9864 8042

CMD ["/run.sh"]
