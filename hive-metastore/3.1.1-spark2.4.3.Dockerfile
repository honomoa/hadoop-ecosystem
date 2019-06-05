FROM honomoa/hive-base:3.1.1-spark2.4.3

HEALTHCHECK CMD netstat -nl | grep 9083 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 9083

CMD ["/run.sh"]
