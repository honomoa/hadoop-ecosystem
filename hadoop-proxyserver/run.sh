#!/bin/bash

$HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR proxyserver -D yarn.web-proxy.address=0.0.0.0:8080
