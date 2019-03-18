#!/bin/bash

install_hadoop(){

	export HADOOP_V="2.7.7"
	export HADOOP_PKG="hadoop-$HADOOP_V.tar.gz"
	export HADOOP_LOCAL_DIR="/usr/local/hadoop"

	wget http://mirrors.standaloneinstaller.com/apache/hadoop/common/hadoop-$HADOOP_V/$HADOOP_PKG

	mkdir -p ${HADOOP_LOCAL_DIR}
	tar -xzvf $HADOOP_PKG -C ${HADOOP_LOCAL_DIR}  --strip-components 1

	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
	envsubst '$HADOOP_V,$HADOOP_PKG,$HADOOP_LOCAL_DIR' < $DIR/../config/hadoop-env.sh  > /etc/profile.d/hadoop-env.sh 

}



_run(){
	install_hadoop

}

_run
