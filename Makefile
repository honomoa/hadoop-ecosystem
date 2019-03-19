
.PHONY: build

build: build-2.7

build-2.7: build-2.7.1

build-2.7.1:
		docker build -t honomoa/hadoop-base:2.7.1 -t honomoa/hadoop-base:2.7.1-java8 -f ./hadoop-base/2.7.1.Dockerfile ./hadoop-base

clean:
		docker rmi openjdk:8 || true
		docker rmi honomoa/hadoop-base:2.7.1 || true
