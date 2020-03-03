FROM honomoa/hadoop-base:3.1.2

HEALTHCHECK CMD curl -f http://localhost:8042/ || exit 1

# Install python3.7
RUN apt update && apt install -y python3 && \
    apt clean && \
    ln -sf /usr/bin/python3 /usr/bin/python

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8042

CMD ["/run.sh"]
