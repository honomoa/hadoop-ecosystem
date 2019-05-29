FROM honomoa/hbase-base:2.1.4-hadoop3.1.2

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 16000 16010

CMD ["/run.sh"]
