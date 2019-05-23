#!/bin/bash

set -e

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="$name=${value}"
  echo ${entry} >> $path
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3

    local var
    local value
    
    echo "Configuring $module"
    echo -n "" > $path
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty $path $name "$value"
    done
}

configure $ZOOKEEPER_CONF_DIR/zoo.cfg zoo.cfg ZK

addProperty $ZOOKEEPER_CONF_DIR/zoo.cfg clientPort 2181
addProperty $ZOOKEEPER_CONF_DIR/zoo.cfg dataDir $ZOOKEEPER_HOME/data
addProperty $ZOOKEEPER_CONF_DIR/zoo.cfg dataLogDir $ZOOKEEPER_HOME/logs

for server in $ZOO_SERVERS; do
    echo " - Setting $server"
    echo "$server" >> $ZOOKEEPER_CONF_DIR/zoo.cfg
done

# Write myid only if it doesn't exist
if [[ ! -f "$ZOOKEEPER_HOME/data/myid" ]]; then
    echo "${ZOO_MY_ID:-1}" > "$ZOOKEEPER_HOME/data/myid"
fi

exec $@
