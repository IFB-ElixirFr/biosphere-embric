#!/bin/bash


set_hostname(){
	export HOSTNAME=$(ss-get nodename)$(ss-get id)
	hostname $HOSTNAME
	hostnamectl set-hostname $HOSTNAME
}

rsa_with_passphrase_exists (){
        file=${1:-~/.ssh/id_rsa}
        rc=0
        if [[ -f $file ]]
        then
                rc=$(expect -c "
                spawn ssh-keygen -yf $file
                expect {
                        -exact \"Enter passphrase:\" {
                                exit 1
                        }
                        eof {
                                exit 0
                        }
                }
                ")
        fi
}
gather_hosts_entries(){
	IFS=','
	for group in $(ss-get ss:groups)
	do
		component_name=${group##*:}
		for id in $(ss-get "${component_name}:ids")
		do
			echo $(ss-get --timeout=3600 ${component_name}.$id:hosts_entry) >> /etc/hosts
		done
	done
}
create_ssh_key(){
        
        #rsa_with_passphrase_exists
        ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

}

_run () {
	
	ss-set component_name $(ss-get nodename)
	create_ssh_key
	set_hostname
	systemctl stop firewalld
	systemctl disable firewalld
	#authorize local ssh 
	cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
	ssh-keyscan $(hostname -s),$(hostname -i),0.0.0.0 >> ~/.ssh/known_hosts
	#publish ssh pub key & /etc/hosts entry
	ss-set public_key  "$(cat /root/.ssh/id_rsa.pub)"
	ss-set hosts_entry "$(ss-get private_ip) $(hostname -s)"
	gather_hosts_entries
	
}



_run
