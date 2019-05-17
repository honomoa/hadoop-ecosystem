#!/bin/bash

journalnode=`echo $HDFS_CONF_dfs_journalnode_edits_dir | perl -pe 's#file://##'`
if [ ! -d $journalnode ]; then
  echo "Journalnode edits directory not found: $journalnode"
  exit 2
fi

$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR journalnode
