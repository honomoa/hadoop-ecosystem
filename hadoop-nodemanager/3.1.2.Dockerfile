FROM honomoa/hadoop-base:3.1.2

HEALTHCHECK CMD curl -f http://localhost:8042/ || exit 1

ENV PYTHON_URL=https://www.python.org/ftp/python/3.7.6/Python-3.7.6.tar.xz

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

EXPOSE 8042

CMD ["/run.sh"]
