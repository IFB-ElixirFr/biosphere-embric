#!/bin/bash -xe


config_spark_env(){
	ss-set component_name $(ss-get nodename)

	listen_hostname=$(ss-get hostname)
	SPARK_MASTER_HOST=${listen_hostname}
	SPARK_MASTER_PORT=7077
	SPARK_MASTER_WEBUI_PORT=$(ss-get spark-web-port)


	cat >> ${SPARK_LOCAL_DIR}/conf/spark-env.sh <<EOF
export SPARK_MASTER_HOST="$SPARK_MASTER_HOST"
export SPARK_MASTER_PORT=${SPARK_MASTER_PORT}
export SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT}
EOF
	

}



add_slaves_config(){

	slave_name=$(ss-get slave_cpnt_name)

	touch ${SPARK_LOCAL_DIR}/conf/slaves

	slaves_list=$(ss-get $slave_name:ids)

	IFS=',' read -ra slave_ids <<< "$slaves_list"

	for id in ${slave_ids[@]} ; do
		slave_state=$(ss-get --timeout=3600 $slave_name.$id:slave-ready)
    		while [[ "$slave_state" != "ready" ]]
		do
			slave_state=$(ss-get --timeout=3600 $slave_name.$id:slave-ready)
		done
	    echo $(ss-get $slave_name.$id:hostname) >> ${SPARK_LOCAL_DIR}/conf/slaves

	done
}



_run(){
	. /etc/profile.d/*spark*
	config_spark_env
	add_slaves_config

	#start master and slaves
	$SPARK_LOCAL_DIR/sbin/start-all.sh
}

_run

