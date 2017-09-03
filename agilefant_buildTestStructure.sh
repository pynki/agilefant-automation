#!/bin/bash

callbackProduct() {
	log "Called callbackProduct() for ID: $1" 0
	if [ "$EXECFORALL_PRODUCTS" == "1" ]; then
		agilefant-automation-deleteProduct $1
	fi
}
callbackProject() {
	log "Called callbackProject() for ID: $1" 0
	if [ "$EXECFORALL_PROJECTS" == "1" ]; then
		agilefant-automation-deleteProject $1
	fi
}
callbackIteration() {
	log "Called callbackIteration() for ID: $1" 0
	if [ "$EXECFORALL_ITERATIONS" == "1" ]; then
		agilefant-automation-deleteIteration $1
	fi
}
callbackStory() {
	log "Called callbackStory() for ID: $1" 0
	if [ "$EXECFORALL_STORIES" == "1" ]; then
		agilefant-automation-deleteStory $1 "DELETE"
	fi
}
callbackTask() {
	log "Called callbackTask() for ID: $1" 0
	if [ "$EXECFORALL_TASKS" == "1" ]; then
		agilefant-automation-deleteTask $1
	fi
}

SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log 101
log 10

source $DIR/conf/agilefant-automation-tools.conf
source $DIR/tools/agilefant-automation-tools.sh

agilefant-automation-login

agilefant-automation-getMainStructure MAIN_JSON

agilefant-automation-execForAll "$MAIN_JSON" "callbackProduct" "callbackProject" "callbackIteration" "callbackStory" "callbackTask"

agilefant-automation-logout

log 11
log 101
exit 0