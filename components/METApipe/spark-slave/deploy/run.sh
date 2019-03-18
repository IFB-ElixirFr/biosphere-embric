#!/bin/bash -xe


authorize_masters_ssh(){
	
	mkdir -p /root/.ssh/
	touch /root/.ssh/authorized_keys
	master_name=$(ss-get --timeout=3600 master_cpnt_name)

	master_list=$(ss-get $master_name:ids)

	IFS=',' read -ra master_ids <<< "$master_list"
	echo "master info $master_list $master_ids" /var/log/ss-debug.log
	for id in ${master_ids[@]} ; do
	    echo "key of master $id ($master_name) "
	    echo $(ss-get $master_name.$id:public_key) >> /root/.ssh/authorized_keys
	done

}


_run(){
	authorize_masters_ssh
	ss-set slave-ready "ready"
}

_run
