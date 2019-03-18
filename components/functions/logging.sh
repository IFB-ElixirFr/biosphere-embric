#!/bin/bash

set_log_files(){
        export BASH_STDOUT="/var/log/bash-$(date +%F-%T)-stdout.log"
        export BASH_STDERR="/var/log/bash-$(date +%F-%T)-stderr.log"
}

debug (){
        if [[ -z "${BASH_STDOUT}" || -z ${BASH_STDERR} ]] ; then
                set_log_files
        fi
        exec 3>&1 4>&2 1>"${BASH_STDOUT}" 2>"${BASH_STDERR}"
        "$@"
        ret=$?
        exec 1>&3 2>&4
        return $?
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo debugging $1
  debug "$@"
fi
