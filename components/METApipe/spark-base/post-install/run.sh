#!/bin/bash

install_scala(){

	export SCALA_V="2.12.7"
	export SCALA_PKG="scala-${SCALA_V}.rpm"
	export SCALA_URL="https://downloads.lightbend.com/scala/${SCALA_V}/${SCALA_PKG}"

	#install scala
	wget $SCALA_URL
	sudo yum -y install ${SCALA_PKG}


		
}



install_spark(){

	export SPARK_V="2.3.2"
	export HADOOP_V="2.7"
	export SPARK_LOCAL_DIR="/usr/local/spark/"
	export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

	envsubst '$SPARK_V,$HADOOP_V,$SPARK_LOCAL_DIR,$JAVA_HOME' < $DIR/../config/spark-env.sh > /etc/profile.d/spark-env.sh

	wget https://archive.apache.org/dist/spark/spark-${SPARK_V}/spark-${SPARK_V}-bin-hadoop2.7.tgz
	sudo mkdir -p ${SPARK_LOCAL_DIR}
	sudo tar -xzvf spark-${SPARK_V}-bin-hadoop2.7.tgz -C ${SPARK_LOCAL_DIR}  --strip-components 1

}

_run(){
	install_scala
	install_spark

}

_run
