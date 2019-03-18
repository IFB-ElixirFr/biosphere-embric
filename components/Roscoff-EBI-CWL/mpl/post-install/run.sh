

set_install_var(){
	export APP_NAME="$1"
	export CAP_APP_NAME=${APP_NAME^^}
	export LOCAL_DIR="/usr/local/$APP_NAME"
	export DATA_DIR="/var/lib/$APP_NAME"
	export ENV_FILE="/etc/profile.d/$APP_NAME-env.sh"
	export SC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
	envsubst '$CAP_APP_NAME,$LOCAL_DIR,$DATA_DIR' < $SC_DIR/../config/app-env.sh > $ENV_FILE
}

_install(){
	mkdir -p $LOCAL_DIR
	mkdir -p $DATA_DIR
	git clone https://github.com/mscheremetjew/workflow-is-cwl/ --branch assembly $LOCAL_DIR
}

_run(){
	set_install_var $COMPONENT_NAME 
	_install
}

_run
