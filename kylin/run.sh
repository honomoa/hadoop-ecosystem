#!/bin/bash

export HIVE_CONF=$HIVE_CONF_DIR

$KYLIN_HOME/bin/kylin.sh start
tail -f /dev/null
