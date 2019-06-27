FROM honomoa/hbase-base:2.1.5-hadoop3.1.2

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 16020 16030

CMD ["/run.sh"]
