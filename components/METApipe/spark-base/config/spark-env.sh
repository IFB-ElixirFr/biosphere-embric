export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export SPARK_V="$SPARK_V"
export SPARK_LOCAL_DIR="$SPARK_LOCAL_DIR"
export HADOOP_V="$HADOOP_V"
export PATH=$PATH:${SPARK_LOCAL_DIR}/bin


