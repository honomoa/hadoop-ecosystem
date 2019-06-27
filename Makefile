
word-dot = $(word $2,$(subst ., ,$1))
SPARK_HADOOP = 3.1.2
HIVE_SPARK = 2.4.3
HBASE_HADOOP = 3.1.2
OOZIE_HADOOP = 2.7.7
DOCKER:=docker

.PHONY: build

build: build-hadoop build-spark build-hive build-hue build-livy build-zookeeper build-hbase build-kylin

build-hadoop: build-hadoop-3.1.2
build-spark: build-spark-2.4.3
build-hive: build-hive-3.1.1
build-hue: build-hue-latest
build-livy: build-livy-0.6.0
build-zookeeper: build-zookeeper-3.4.14 build-zookeeper-3.5.5
build-hbase: build-hbase-2.1.5
build-kylin: build-kylin-2.6.2
build-oozie: build-oozie-4.3.1 build-oozie-5.1.0

build-hadoop-%:
		$(DOCKER) build -t honomoa/hadoop-base:$* -f ./hadoop-base/$*.Dockerfile ./hadoop-base
		$(DOCKER) build -t honomoa/hadoop-namenode:$* -f ./hadoop-namenode/$*.Dockerfile ./hadoop-namenode
		$(DOCKER) build -t honomoa/hadoop-datanode:$* -f ./hadoop-datanode/$*.Dockerfile ./hadoop-datanode
		$(DOCKER) build -t honomoa/hadoop-journalnode:$* -f ./hadoop-journalnode/$*.Dockerfile ./hadoop-journalnode
		$(DOCKER) build -t honomoa/hadoop-secondarynamenode:$* -f ./hadoop-secondarynamenode/$*.Dockerfile ./hadoop-secondarynamenode
		$(DOCKER) build -t honomoa/hadoop-resourcemanager:$* -f ./hadoop-resourcemanager/$*.Dockerfile ./hadoop-resourcemanager
		$(DOCKER) build -t honomoa/hadoop-nodemanager:$* -f ./hadoop-nodemanager/$*.Dockerfile ./hadoop-nodemanager
		$(DOCKER) build -t honomoa/hadoop-timelineserver:$* -f ./hadoop-timelineserver/$*.Dockerfile ./hadoop-timelineserver
		$(DOCKER) build -t honomoa/hadoop-datanodemanager:$* -f ./hadoop-datanodemanager/$*.Dockerfile ./hadoop-datanodemanager

build-spark-%:
		$(DOCKER) build -t honomoa/spark-base:$*-hadoop$(SPARK_HADOOP) -f ./spark-base/$*-hadoop$(SPARK_HADOOP).Dockerfile ./spark-base
		$(DOCKER) build -t honomoa/spark-historyserver:$*-hadoop$(SPARK_HADOOP) -f ./spark-historyserver/$*-hadoop$(SPARK_HADOOP).Dockerfile ./spark-historyserver

build-hive-%:
		$(eval MAJOR_MINOR = $(call word-dot,$*,1).$(call word-dot,$*,2).0)
		$(DOCKER) build -t honomoa/hive-base:$*-spark$(HIVE_SPARK) -f ./hive-base/$*-spark$(HIVE_SPARK).Dockerfile ./hive-base
		$(DOCKER) build -t honomoa/hive-server:$*-spark$(HIVE_SPARK) -f ./hive-server/$*-spark$(HIVE_SPARK).Dockerfile ./hive-server
		$(DOCKER) build -t honomoa/hive-metastore:$*-spark$(HIVE_SPARK) -f ./hive-metastore/$*-spark$(HIVE_SPARK).Dockerfile ./hive-metastore
		$(DOCKER) build -t honomoa/hive-metastore-postgresql:$(MAJOR_MINOR) -f ./hive-metastore-postgresql/$(MAJOR_MINOR).Dockerfile ./hive-metastore-postgresql

build-hue-%:
		$(DOCKER) build -t honomoa/gethue:$* -f ./hue/$*.Dockerfile ./hue

build-livy-%:
		$(DOCKER) build -t honomoa/livy:$* -f ./livy/$*-spark2.4.3.Dockerfile ./livy

build-zookeeper-%:
		$(DOCKER) build -t honomoa/zookeeper:$* -f ./zookeeper/$*.Dockerfile ./zookeeper

build-hbase-%:
		$(DOCKER) build -t honomoa/hbase-base:$*-hadoop$(HBASE_HADOOP) -f ./hbase-base/$*-hadoop$(HBASE_HADOOP).Dockerfile ./hbase-base
		$(DOCKER) build -t honomoa/hbase-master:$*-hadoop$(HBASE_HADOOP) -f ./hbase-master/$*-hadoop$(HBASE_HADOOP).Dockerfile ./hbase-master
		$(DOCKER) build -t honomoa/hbase-regionserver:$*-hadoop$(HBASE_HADOOP) -f ./hbase-regionserver/$*-hadoop$(HBASE_HADOOP).Dockerfile ./hbase-regionserver
		$(DOCKER) build -t honomoa/hbase-thrift:$*-hadoop$(HBASE_HADOOP) -f ./hbase-thrift/$*-hadoop$(HBASE_HADOOP).Dockerfile ./hbase-thrift

build-kylin-%:
		$(DOCKER) build -t honomoa/kylin:$* -f ./kylin/$*.Dockerfile ./kylin

build-oozie-%:
		$(DOCKER) build -t honomoa/oozie:$*-hadoop$(OOZIE_HADOOP) -f ./oozie/$*-hadoop$(OOZIE_HADOOP).Dockerfile ./oozie

.PHONY: clean
clean: clean-hive clean-spark clean-livy clean-zookeeper clean-hbase clean-kylin clean-hadoop clean-hue 

clean-hadoop: clean-hadoop-3.1.2
clean-spark: clean-spark-2.4.3
clean-hive: clean-hive-3.1.1
clean-hue: clean-hue-latest
clean-livy: clean-livy-0.6.0
clean-zookeeper: clean-zookeeper-3.4.14 clean-zookeeper-3.5.5
clean-hbase: clean-hbase-2.1.5
clean-kylin: clean-kylin-2.6.2
clean-oozie: clean-oozie-5.1.0

clean-hadoop-%:
		$(DOCKER) rmi honomoa/hadoop-namenode:$* || true
		$(DOCKER) rmi honomoa/hadoop-datanode:$* || true
		$(DOCKER) rmi honomoa/hadoop-journalnode:$* || true
		$(DOCKER) rmi honomoa/hadoop-secondarynamenode:$* || true
		$(DOCKER) rmi honomoa/hadoop-resourcemanager:$* || true
		$(DOCKER) rmi honomoa/hadoop-nodemanager:$* || true
		$(DOCKER) rmi honomoa/hadoop-timelineserver:$* || true
		$(DOCKER) rmi honomoa/hadoop-base:$* || true
		$(DOCKER) rmi openjdk:8 || true

clean-spark-%:
		$(DOCKER) rmi honomoa/hadoop-historyserver:$*-hadoop$(SPARK_HADOOP) || true
		$(DOCKER) rmi honomoa/hadoop-base:$*-hadoop$(SPARK_HADOOP) || true

clean-hive-%:
		$(eval MAJOR_MINOR = $(call word-dot,$*,1).$(call word-dot,$*,2).0)
		$(DOCKER) rmi honomoa/hive-metastore:$*-spark$(HIVE_SPARK) || true
		$(DOCKER) rmi honomoa/hive-server:$*-spark$(HIVE_SPARK) || true
		$(DOCKER) rmi honomoa/hive-base:$*-spark$(HIVE_SPARK) || true
		$(DOCKER) rmi honomoa/hive-metastore-postgresql:$(MAJOR_MINOR) || true

clean-hue-%:
		$(DOCKER) rmi honomoa/gethue:$* || true

clean-livy-%:
		$(DOCKER) rmi honomoa/livy:$* || true

clean-zookeeper-%:
		$(DOCKER) rmi honomoa/zookeeper:$* || true

clean-hbase-%:
		$(DOCKER) rmi honomoa/hbase-master:$*-hadoop3.1.2 || true
		$(DOCKER) rmi honomoa/hbase-regionserver:$*-hadoop3.1.2 || true
		$(DOCKER) rmi honomoa/hbase-thrift:$*-hadoop3.1.2 || true
		$(DOCKER) rmi honomoa/hbase-base:$*-hadoop3.1.2 || true

clean-kylin-%:
		$(DOCKER) rmi honomoa/kylin:$* || true

clean-oozie-%:
		$(DOCKER) rmi honomoa/oozie:$*-hadoop$(OOZIE_HADOOP) || true

.PHONY: push
push: push-hadoop push-spark push-hive push-hue push-livy push-zookeeper push-hbase push-kylin

push-hadoop: push-hadoop-3.1.2
push-spark: push-spark-2.4.3
push-hive: push-hive-3.1.1
push-hue: push-hue-latest
push-livy: push-livy-0.6.0
push-zookeeper: push-zookeeper-3.4.14 push-zookeeper-3.5.5
push-hbase: push-hbase-2.1.5
push-kylin: push-kylin-2.6.2
push-oozie: push-oozie-4.3.1 push-oozie-5.1.0

push-hadoop-%:
		$(DOCKER) push honomoa/hadoop-base:$*
		$(DOCKER) push honomoa/hadoop-namenode:$*
		$(DOCKER) push honomoa/hadoop-datanode:$*
		$(DOCKER) push honomoa/hadoop-journalnode:$*
		$(DOCKER) push honomoa/hadoop-secondarynamenode:$*
		$(DOCKER) push honomoa/hadoop-resourcemanager:$*
		$(DOCKER) push honomoa/hadoop-nodemanager:$*
		$(DOCKER) push honomoa/hadoop-timelineserver:$*

push-spark-%:
		$(DOCKER) push honomoa/spark-historyserver:$*-hadoop$(SPARK_HADOOP)
		$(DOCKER) push honomoa/spark-base:$*-hadoop$(SPARK_HADOOP)

push-hive-%:
		$(eval MAJOR_MINOR = $(call word-dot,$*,1).$(call word-dot,$*,2).0)
		$(DOCKER) push honomoa/hive-base:$*-spark$(HIVE_SPARK)
		$(DOCKER) push honomoa/hive-server:$*-spark$(HIVE_SPARK)
		$(DOCKER) push honomoa/hive-metastore:$*-spark$(HIVE_SPARK)
		$(DOCKER) push honomoa/hive-metastore-postgresql:$(MAJOR_MINOR)

push-hue-%:
		$(DOCKER) push honomoa/gethue:$*

push-livy-%:
		$(DOCKER) push honomoa/livy:$*

push-zookeeper-%:
		$(DOCKER) push honomoa/zookeeper:$*

push-hbase-%:
		$(DOCKER) push honomoa/hbase-base:$*-hadoop$(HBASE_HADOOP)
		$(DOCKER) push honomoa/hbase-master:$*-hadoop$(HBASE_HADOOP)
		$(DOCKER) push honomoa/hbase-regionserver:$*-hadoop$(HBASE_HADOOP)
		$(DOCKER) push honomoa/hbase-thrift:$*-hadoop$(HBASE_HADOOP)

push-kylin-%:
		$(DOCKER) push honomoa/kylin:$*

push-oozie-%:
		$(DOCKER) push honomoa/oozie:$*-hadoop$(OOZIE_HADOOP)

pull: pull-hadoop pull-spark pull-hive pull-hue pull-livy pull-zookeeper pull-hbase pull-kylin

pull-hadoop: pull-hadoop-3.1.2
pull-spark: pull-spark-2.4.3
pull-hive: pull-hive-3.1.1
pull-hue: pull-hue-latest
pull-livy: pull-livy-0.6.0
pull-zookeeper: pull-zookeeper-3.4.14 pull-zookeeper-3.5.5
pull-hbase: pull-hbase-2.1.5
pull-kylin: pull-kylin-2.6.2
pull-oozie: pull-oozie-4.3.1 pull-oozie-5.1.0

pull-hadoop-%:
		$(DOCKER) pull honomoa/hadoop-base:$*
		$(DOCKER) pull honomoa/hadoop-namenode:$*
		$(DOCKER) pull honomoa/hadoop-datanode:$*
		$(DOCKER) pull honomoa/hadoop-journalnode:$*
		$(DOCKER) pull honomoa/hadoop-secondarynamenode:$*
		$(DOCKER) pull honomoa/hadoop-resourcemanager:$*
		$(DOCKER) pull honomoa/hadoop-nodemanager:$*
		$(DOCKER) pull honomoa/hadoop-timelineserver:$*

pull-spark-%:
		$(DOCKER) pull honomoa/spark-historyserver:$*-hadoop$(SPARK_HADOOP)
		$(DOCKER) pull honomoa/spark-base:$*-hadoop$(SPARK_HADOOP)

pull-hive-%:
		$(eval MAJOR_MINOR = $(call word-dot,$*,1).$(call word-dot,$*,2).0)
		$(DOCKER) pull honomoa/hive-base:$*-spark$(HIVE_SPARK)
		$(DOCKER) pull honomoa/hive-server:$*-spark$(HIVE_SPARK)
		$(DOCKER) pull honomoa/hive-metastore:$*-spark$(HIVE_SPARK)
		$(DOCKER) pull honomoa/hive-metastore-postgresql:$(MAJOR_MINOR)

pull-hue-%:
		$(DOCKER) pull honomoa/gethue:$*

pull-livy-%:
		$(DOCKER) pull honomoa/livy:$*

pull-zookeeper-%:
		$(DOCKER) pull honomoa/zookeeper:$*

pull-hbase-%:
		$(DOCKER) pull honomoa/hbase-base:$*-hadoop$(HBASE_HADOOP)
		$(DOCKER) pull honomoa/hbase-master:$*-hadoop$(HBASE_HADOOP)
		$(DOCKER) pull honomoa/hbase-regionserver:$*-hadoop$(HBASE_HADOOP)
		$(DOCKER) pull honomoa/hbase-thrift:$*-hadoop$(HBASE_HADOOP)

pull-kylin-%:
		$(DOCKER) pull honomoa/kylin:$*

pull-oozie-%:
		$(DOCKER) pull honomoa/oozie:$*-hadoop$(OOZIE_HADOOP)
