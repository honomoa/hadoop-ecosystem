#!/bin/bash

namedir=`echo $HDFS_CONF_dfs_namenode_checkpoint_dir | perl -pe 's#file://##'`
if [ ! -d $namedir ]; then
  echo "Secondary namenode name directory not found: $namedir"
  exit 2
fi

$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR secondarynamenode
