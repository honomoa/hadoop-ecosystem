#!/bin/bash

${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.history.HistoryServer ${SPARK_HISTORY_FS_LOGDIRECTORY}
