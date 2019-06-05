
.PHONY: build

build: build-hadoop build-spark build-hive build-hue build-livy build-zk build-hbase build-kylin

build-hadoop: build-hadoop-3.1.2
build-spark: build-spark-2.4.3
build-hive: build-hive-3.1.1
build-hue: build-hue-latest
build-livy: build-livy-0.6.0
build-zk: build-zk-3.4.14
build-hbase: build-hbase-2.1.4
build-kylin: build-kylin-2.6.2

build-hadoop-3.1.2:
		docker build -t honomoa/hadoop-base:3.1.2 -f ./hadoop-base/3.1.2.Dockerfile ./hadoop-base
		docker build -t honomoa/hadoop-namenode:3.1.2 -f ./hadoop-namenode/3.1.2.Dockerfile ./hadoop-namenode
		docker build -t honomoa/hadoop-datanode:3.1.2 -f ./hadoop-datanode/3.1.2.Dockerfile ./hadoop-datanode
		docker build -t honomoa/hadoop-journalnode:3.1.2 -f ./hadoop-journalnode/3.1.2.Dockerfile ./hadoop-journalnode
		docker build -t honomoa/hadoop-secondarynamenode:3.1.2 -f ./hadoop-secondarynamenode/3.1.2.Dockerfile ./hadoop-secondarynamenode
		docker build -t honomoa/hadoop-resourcemanager:3.1.2 -f ./hadoop-resourcemanager/3.1.2.Dockerfile ./hadoop-resourcemanager
		docker build -t honomoa/hadoop-nodemanager:3.1.2 -f ./hadoop-nodemanager/3.1.2.Dockerfile ./hadoop-nodemanager
		docker build -t honomoa/hadoop-timelineserver:3.1.2 -f ./hadoop-timelineserver/3.1.2.Dockerfile ./hadoop-timelineserver
		docker build -t honomoa/hadoop-datanodemanager:3.1.2 -f ./hadoop-datanodemanager/3.1.2.Dockerfile ./hadoop-datanodemanager

build-spark-2.4.3:
		docker build -t honomoa/spark-base:2.4.3-hadoop3.1.2 -f ./spark-base/2.4.3-hadoop3.1.2.Dockerfile ./spark-base

build-hive-3.1.1:
		docker build -t honomoa/hive-base:3.1.1-spark2.4.3 -f ./hive-base/3.1.1-spark2.4.3.Dockerfile ./hive-base
		docker build -t honomoa/hive-server:3.1.1-spark2.4.3 -f ./hive-server/3.1.1-spark2.4.3.Dockerfile ./hive-server
		docker build -t honomoa/hive-metastore:3.1.1-spark2.4.3 -f ./hive-metastore/3.1.1-spark2.4.3.Dockerfile ./hive-metastore
		docker build -t honomoa/hive-metastore-postgresql:3.1.0 -f ./hive-metastore-postgresql/3.1.0.Dockerfile ./hive-metastore-postgresql

build-hue-latest:
		docker build -t honomoa/gethue:latest -f ./hue/Dockerfile ./hue

build-livy-0.6.0:
		docker build -t honomoa/livy:0.6.0 -f ./livy/0.6.0-spark2.4.3.Dockerfile ./livy

build-zk-3.4.14:
		docker build -t honomoa/zookeeper:3.4.14 -f ./zookeeper/3.4.14.Dockerfile ./zookeeper

build-hbase-2.1.4:
		docker build -t honomoa/hbase-base:2.1.4-hadoop3.1.2 -f ./hbase-base/2.1.4-hadoop3.1.2.Dockerfile ./hbase-base
		docker build -t honomoa/hbase-master:2.1.4-hadoop3.1.2 -f ./hbase-master/2.1.4-hadoop3.1.2.Dockerfile ./hbase-master
		docker build -t honomoa/hbase-regionserver:2.1.4-hadoop3.1.2 -f ./hbase-regionserver/2.1.4-hadoop3.1.2.Dockerfile ./hbase-regionserver
		docker build -t honomoa/hbase-thrift:2.1.4-hadoop3.1.2 -f ./hbase-thrift/2.1.4-hadoop3.1.2.Dockerfile ./hbase-thrift

build-kylin-2.6.2:
		docker build -t honomoa/kylin:2.6.2 -f ./kylin/2.6.2.Dockerfile ./kylin

clean: clean-hive clean-spark clean-livy clean-zk clean-hbase clean-kylin clean-hadoop clean-hue 

clean-hadoop: clean-hadoop-3.1.2
clean-spark: clean-spark-2.4.3
clean-hive: clean-hive-3.1.1
clean-hue: clean-hue-latest
clean-livy: clean-livy-0.6.0
clean-zk: clean-zk-3.4.14
clean-hbase: clean-hbase-2.1.4
clean-kylin: clean-kylin-2.6.2

clean-hadoop-3.1.2:
		docker rmi honomoa/hadoop-namenode:3.1.2 || true
		docker rmi honomoa/hadoop-datanode:3.1.2 || true
		docker rmi honomoa/hadoop-journalnode:3.1.2 || true
		docker rmi honomoa/hadoop-secondarynamenode:3.1.2 || true
		docker rmi honomoa/hadoop-resourcemanager:3.1.2 || true
		docker rmi honomoa/hadoop-nodemanager:3.1.2 || true
		docker rmi honomoa/hadoop-timelineserver:3.1.2 || true
		docker rmi honomoa/hadoop-base:3.1.2 || true
		docker rmi openjdk:8 || true

clean-spark-2.4.3:
		docker rmi honomoa/hadoop-base:2.4.3-hadoop3.1.2 || true

clean-hive-3.1.1:
		docker rmi honomoa/hive-metastore:3.1.1-spark2.4.3 || true
		docker rmi honomoa/hive-server:3.1.1-spark2.4.3 || true
		docker rmi honomoa/hive-base:3.1.1-spark2.4.3 || true
		docker rmi honomoa/hive-metastore-postgresql:3.1.0 || true

clean-hue-latest:
		docker rmi honomoa/gethue:latest || true

clean-livy-0.6.0:
		docker rmi honomoa/livy:0.6.0 || true

clean-zk-3.4.14:
		docker rmi honomoa/zookeeper:3.4.14 || true

clean-hbase-2.1.4:
		docker rmi honomoa/hbase-master:2.1.4-hadoop3.1.2 || true
		docker rmi honomoa/hbase-regionserver:2.1.4-hadoop3.1.2 || true
		docker rmi honomoa/hbase-thrift:2.1.4-hadoop3.1.2 || true
		docker rmi honomoa/hbase-base:2.1.4-hadoop3.1.2 || true

clean-kylin-2.6.2:
		docker rmi honomoa/kylin:2.6.2 || true

push: push-hadoop push-spark push-hive push-hue push-livy push-zk push-hbase push-kylin

push-hadoop: push-hadoop-3.1.2
push-spark: push-spark-2.4.3
push-hive: push-hive-3.1.1
push-hue: push-hue-latest
push-livy: push-livy-0.6.0
push-zk: push-zk-3.4.14
push-hbase: push-hbase-2.1.4
push-kylin: push-kylin-2.6.2

push-hadoop-3.1.2:
		docker push honomoa/hadoop-base:3.1.2
		docker push honomoa/hadoop-namenode:3.1.2
		docker push honomoa/hadoop-datanode:3.1.2
		docker push honomoa/hadoop-journalnode:3.1.2
		docker push honomoa/hadoop-secondarynamenode:3.1.2
		docker push honomoa/hadoop-resourcemanager:3.1.2
		docker push honomoa/hadoop-nodemanager:3.1.2
		docker push honomoa/hadoop-timelineserver:3.1.2

push-spark-2.4.3:
		docker push honomoa/spark-base:2.4.3-hadoop3.1.2

push-hive-3.1.1:
		docker push honomoa/hive-base:3.1.1-spark2.4.3
		docker push honomoa/hive-server:3.1.1-spark2.4.3
		docker push honomoa/hive-metastore:3.1.1-spark2.4.3
		docker push honomoa/hive-metastore-postgresql:3.1.0

push-hue-latest:
		docker push honomoa/gethue:latest

push-livy-0.6.0:
		docker push honomoa/livy:0.6.0

push-zk-3.4.14:
		docker push honomoa/zookeeper:3.4.14

push-hbase-2.1.4:
		docker push honomoa/hbase-base:2.1.4-hadoop3.1.2
		docker push honomoa/hbase-master:2.1.4-hadoop3.1.2
		docker push honomoa/hbase-regionserver:2.1.4-hadoop3.1.2
		docker push honomoa/hbase-thrift:2.1.4-hadoop3.1.2

push-kylin-2.6.2:
		docker push honomoa/kylin:2.6.2
