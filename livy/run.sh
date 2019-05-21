#!/bin/bash

livy-server start
tail -f $LIVY_HOME/logs/livy-root-server.out
