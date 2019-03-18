#!/bin/bash -xe


config_hadoop_slaves(){

	#create if not exist and 
	#add slave to hadoop config
	. ~/.bashrc
	touch ${HADOOP_LOCAL_DIR}/etc/hadoop/slaves

	slave_name=$(ss-get slave_cpnt_name)

	slaves_list=$(ss-get $slave_name:ids)

	IFS=',' read -ra slave_ids <<< "$slaves_list"
	truncate -s0 ${HADOOP_LOCAL_DIR}/etc/hadoop/slaves
	touch ~/.ssh/known_hosts
	#wait for all slave scripts to set hostname
	for id in ${slave_ids[@]} ; do
	    echo $(ss-get $slave_name.$id:hostname) >> ${HADOOP_LOCAL_DIR}/etc/hadoop/slaves
	    ssh-keyscan $(grep -e $slave_name$id -m 1 /etc/hosts|tr -s ' ' ',' ) >> ~/.ssh/known_hosts
	    scp ${HADOOP_LOCAL_DIR}/etc/hadoop/core-site.xml $slave_name$id:${HADOOP_LOCAL_DIR}/etc/hadoop/core-site.xml 
	    scp ${HADOOP_LOCAL_DIR}/etc/hadoop/hdfs-site.xml $slave_name$id:${HADOOP_LOCAL_DIR}/etc/hadoop/hdfs-site.xml 
	done
}

#$1 = input $2 output $3 = name  $4 = value
add_property(){
	if [[ "$1" == "$2" ]];
	then
		xmlstarlet edit --inplace -s '//configuration' -t elem -n "property" \
		-s '//configuration/property[last()]' -t elem -n "name"  -v $3 \
		-s '//configuration/property[last()]' -t elem -n "value" -v $4 \
		$1 

	else
		xmlstarlet edit -s '//configuration' -t elem -n "property" \
		-s '//configuration/property[last()]' -t elem -n "name"  -v $3 \
		-s '//configuration/property[last()]' -t elem -n "value" -v $4 \
		$1 | xmlstarlet fo > $2
	fi
	
}
config_hadoop_xml(){
	add_property "${HADOOP_LOCAL_DIR}/share/hadoop/common/templates/core-site.xml" "${HADOOP_LOCAL_DIR}/etc/hadoop/core-site.xml" "fs.default.name" "hdfs://$(hostname -s):9000"
	add_property "${HADOOP_LOCAL_DIR}/share/hadoop/hdfs/templates/hdfs-site.xml" "${HADOOP_LOCAL_DIR}/etc/hadoop/hdfs-site.xml" "dfs.replication" "1"
	add_property "${HADOOP_LOCAL_DIR}/etc/hadoop/hdfs-site.xml" "${HADOOP_LOCAL_DIR}/etc/hadoop/hdfs-site.xml" "dfs.data.dir" "/srv/hadoop/datanode" 
	add_property "${HADOOP_LOCAL_DIR}/etc/hadoop/hdfs-site.xml" "${HADOOP_LOCAL_DIR}/etc/hadoop/hdfs-site.xml" "dfs.name.dir" "/srv/hadoop/namenode"
		
}



_run(){
	. /etc/profile.d/*hadoop*
	config_hadoop_xml
	config_hadoop_slaves
	#format hdfs
	#add hdfs ui
	${HADOOP_LOCAL_DIR}/bin/hdfs namenode -format
	${HADOOP_LOCAL_DIR}/sbin/start-dfs.sh
}

_run
