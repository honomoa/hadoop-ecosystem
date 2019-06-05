FROM honomoa/hive-base:3.1.1-spark2.4.3

HEALTHCHECK CMD netstat -nl | egrep "10000|10002" > /dev/null; if [ 0 != $? ]; then exit 1; fi;

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 10000 10002

CMD ["/run.sh"]
