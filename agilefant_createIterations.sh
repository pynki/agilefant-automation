#!/bin/bash

callbackProject() {
	log "Called callbackProject() for ID: $1" 1	
	PROJECT_NAME=$(echo "$2" | jq -r '. | .data.name')
	local i
	for i in ${!ITERATION_NAMES[@]}; 
	do
		CONV_NAME=$(echo "${ITERATION_NAMES[$i]}" | sed 's/_/ /g')
		CONV_DESCRIPTION=$(echo "${ITERATION_DESCRIPTIONS[$i]}" | sed 's/_/ /g')
		CONV_START_DATE=$(echo "${ITERATION_START_DATES[$i]}" | sed 's/_/ /')
		CONV_END_DATE=$(echo "${ITERATION_END_DATES[$i]}" | sed 's/_/ /')	
		convertDateToEpoch START_DATE "$CONV_START_DATE"
		convertDateToEpoch END_DATE "$CONV_END_DATE"
		if [ -z "$1" ]; then
			ITERATION='{"iteration.startDate": '$START_DATE', "iteration.endDate": '$END_DATE', "assigneesChanged": true,"iteration.name": "'${ITERATION_NAMES[$i]}' ['$PROJECT_NAME']", "iteration.description": "'$CONV_DESCRIPTION'", "teamsChanged": true, "assigneeIds": [3], "teamIds": [2]}'
		else
			ITERATION='{"parentBacklogId": '$1', "iteration.startDate": '$START_DATE', "iteration.endDate": '$END_DATE', "assigneesChanged": true,"iteration.name": "'${ITERATION_NAMES[$i]}' ['$PROJECT_NAME']", "iteration.description": "'$CONV_DESCRIPTION'", "teamsChanged": true, "assigneeIds": [3], "teamIds": [2]}'
		fi
		agilefant-API-createIteration "$ITERATION" RETURN_VAL NEW_ID	
	done
	echo "NEW ITERATIONS_ID: $NEW_ID"
}

SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log 101
log 10

source $DIR/agilefant-API/agilefant-API-tools.sh

ITERATION_NAMES=( ` echo $ITERATION_NAMES_ARR ` )
ITERATION_DESCRIPTIONS=( ` echo $ITERATION_DESCRIPTIONS_ARR ` )
ITERATION_START_DATES=( ` echo $ITERATION_START_DATES_ARR ` )
ITERATION_END_DATES=( ` echo $ITERATION_END_DATES_ARR ` )
LENGTH_SUM=$((${#ITERATION_NAMES[@]}+${#ITERATION_DESCRIPTIONS[@]}+${#ITERATION_START_DATES[@]}+${#ITERATION_END_DATES[@]}))
if [ $(( $LENGTH_SUM % 4 )) -eq "0" ]; then
	log "Arrays OK" 1
	agilefant-API-login	
	if [ "$CREATE_STANDALONE" == "1" ]; then
		callbackProject "" '{"data": {"name":"Standalone"}}'
	else
		if [ ! -z "$PROJECT_IDS_ARR" ]; then
			PROJECT_IDS=( ` echo $PROJECT_IDS_ARR ` )
			for p in ${PROJECT_IDS[@]};
			do
				agilefant-API-getProject-simple PROJECT_JSON_SIMPLE $p
				callbackProject $p "$PROJECT_JSON_SIMPLE"
			done
		else 
			# create iterations
			agilefant-API-getMainStructure LOCAL_JSON
			agilefant-API-execForAll "$LOCAL_JSON" "" "callbackProject" "" "" ""
		fi
	fi
	agilefant-API-logout
else 
	log "Arrays not OK. Please revie the array length. Exiting" 1
fi

log 11
log 101
exit 0