#!/bin/bash

# Set some sensible defaults
export HOSTNAME=${HOSTNAME:-`hostname -f`}
export CORE_CONF_fs_defaultFS=${CORE_CONF_fs_defaultFS:-hdfs://$HOSTNAME:8020}

function addConfiguration() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="s|^$name.*|$name = $value|"
  local commented_entry="s|^#$name.*|$name = $value|"
  grep -q "^$name" $path && sed -i -e "$entry" $path || grep -q "^#$name" $path && sed -i -e "$commented_entry" $path || echo "$name=$value" >> $path
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3
    local func=${4:-addConfiguration}

    local var
    local value

    echo "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        $func $path $name "$value"
    done
}

function install_r_package() {
    local module=$1
    local envPrefix=$2
    echo "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        cran=${!var}
        if [[ -d /usr/local/lib/R/site-library/$name ]]; then
            echo " - Skip R $name"
        else
            echo " - Install R $name from $cran"
            R -e "install.packages('$name', repos='$cran')" >> $ZEPPELIN_HOME/logs/install_r_package.log
        fi
    done
}

configure $HADOOP_CONF_DIR/core-site.xml core CORE_CONF
configure $HADOOP_CONF_DIR/hdfs-site.xml hdfs HDFS_CONF
configure $HADOOP_CONF_DIR/yarn-site.xml yarn YARN_CONF
configure $HADOOP_CONF_DIR/httpfs-site.xml httpfs HTTPFS_CONF
configure $HADOOP_CONF_DIR/kms-site.xml kms KMS_CONF
configure $HADOOP_CONF_DIR/mapred-site.xml mapred MAPRED_CONF
configure $ZEPPELIN_CONF_DIR/zeppelin-site.xml zeppelin ZEPPELIN_SITE_CONF

install_r_package cran R_PACKAGE

if [ "$MULTIHOMED_NETWORK" = "1" ]; then
    echo "Configuring for multihomed network"

    # HDFS
    addConfiguration $HADOOP_CONF_DIR/hdfs-site.xml dfs.namenode.rpc-bind-host 0.0.0.0
    addConfiguration $HADOOP_CONF_DIR/hdfs-site.xml dfs.namenode.servicerpc-bind-host 0.0.0.0
    addConfiguration $HADOOP_CONF_DIR/hdfs-site.xml dfs.namenode.http-bind-host 0.0.0.0
    addConfiguration $HADOOP_CONF_DIR/hdfs-site.xml dfs.namenode.https-bind-host 0.0.0.0
    addConfiguration $HADOOP_CONF_DIR/hdfs-site.xml dfs.client.use.datanode.hostname true
    addConfiguration $HADOOP_CONF_DIR/hdfs-site.xml dfs.datanode.use.datanode.hostname true

    # YARN
    addConfiguration $HADOOP_CONF_DIR/yarn-site.xml yarn.resourcemanager.bind-host 0.0.0.0
    addConfiguration $HADOOP_CONF_DIR/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0
    addConfiguration $HADOOP_CONF_DIR/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0
    addConfiguration $HADOOP_CONF_DIR/yarn-site.xml yarn.timeline-service.bind-host 0.0.0.0

    # MAPRED
    addConfiguration $HADOOP_CONF_DIR/mapred-site.xml yarn.nodemanager.bind-host 0.0.0.0

    # ZEPPELIN
    addConfiguration $ZEPPELIN_CONF_DIR/zeppelin-site.xml zeppelin.server.addr 0.0.0.0
    addConfiguration $ZEPPELIN_CONF_DIR/zeppelin-site.xml zeppelin.server.port 8080
fi

if [ -n "$GANGLIA_HOST" ]; then
    mv $HADOOP_CONF_DIR/hadoop-metrics.properties $HADOOP_CONF_DIR/hadoop-metrics.properties.orig
    mv $HADOOP_CONF_DIR/hadoop-metrics2.properties $HADOOP_CONF_DIR/hadoop-metrics2.properties.orig

    for module in mapred jvm rpc ugi; do
        echo "$module.class=org.apache.hadoop.metrics.ganglia.GangliaContext31"
        echo "$module.period=10"
        echo "$module.servers=$GANGLIA_HOST:8649"
    done > $HADOOP_CONF_DIR/hadoop-metrics.properties
    
    for module in namenode datanode resourcemanager nodemanager mrappmaster jobhistoryserver; do
        echo "$module.sink.ganglia.class=org.apache.hadoop.metrics2.sink.ganglia.GangliaSink31"
        echo "$module.sink.ganglia.period=10"
        echo "$module.sink.ganglia.supportsparse=true"
        echo "$module.sink.ganglia.slope=jvm.metrics.gcCount=zero,jvm.metrics.memHeapUsedM=both"
        echo "$module.sink.ganglia.dmax=jvm.metrics.threadsBlocked=70,jvm.metrics.memHeapUsedM=40"
        echo "$module.sink.ganglia.servers=$GANGLIA_HOST:8649"
    done > $HADOOP_CONF_DIR/hadoop-metrics2.properties
fi

function wait_for_it()
{
    local serviceport=$1
    local service=${serviceport%%:*}
    local port=${serviceport#*:}
    local retry_seconds=5
    local max_try=100
    let i=1

    nc -z $service $port
    result=$?

    until [ $result -eq 0 ]; do
      echo "[$i/$max_try] check for ${service}:${port}..."
      echo "[$i/$max_try] ${service}:${port} is not available yet"
      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi
      
      echo "[$i/$max_try] try in ${retry_seconds}s once again ..."
      let "i++"
      sleep $retry_seconds

      nc -z $service $port
      result=$?
    done
    echo "[$i/$max_try] $service:${port} is available."
}

for i in ${SERVICE_PRECONDITION[@]}
do
    wait_for_it ${i}
done

exec $@
