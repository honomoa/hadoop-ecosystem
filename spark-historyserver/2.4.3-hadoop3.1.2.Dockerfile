FROM honomoa/spark-base:2.4.3-hadoop3.1.2

HEALTHCHECK CMD curl -f http://localhost:18080/ || exit 1

ENV SPARK_HISTORY_FS_LOGDIRECTORY=/spark-logs

EXPOSE 18080

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
