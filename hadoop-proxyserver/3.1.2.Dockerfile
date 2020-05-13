FROM honomoa/hadoop-base:3.1.2

HEALTHCHECK CMD jps | grep WebAppProxyServer

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8080

CMD ["/run.sh"]
