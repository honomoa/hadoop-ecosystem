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
