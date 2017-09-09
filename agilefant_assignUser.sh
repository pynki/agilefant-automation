#!/bin/bash

# callback project to find the actual(more than one possibly) iteration!

callbackStory() {
	log "Called callbackStory() for ID: $1" 0
	local STORY_STATE=$(echo "$2" | jq -r '. | .data.state')
	local STORY_TASKS=$(echo "$2" | jq '. | .tasks')
	local STORY_TASKS_COUNT=$(echo "$2" | jq '. | .tasks | length')

	# moving to user1 and set all tasks NOP_STARTED and move them to user1
	if [ "$STORY_STATE" == "NOT_STARTED" ]; then
		log "Performing actions on story $1 with state $STORY_STATE" 1
		local STORY_JSON='{"storyId": '$1',"usersChanged": true, "userIds": ['$USER1_ID']}'
		agilefant-API-storeStory "$STORY_JSON" RETURN_VAL
		local c
		for c in $(seq 1 "$STORY_TASKS_COUNT");
		do
			local TASK_ID=$(echo "$2" | jq --arg C $c '. | .tasks[$C | tonumber -1].id')
			
			local TASK_JSON='{"taskId": '$TASK_ID', "responsiblesChanged": true,  "newResponsibles": ['$USER1_ID'], "task.state": "NOT_STARTED"}'
			agilefant-API-storeTask "$TASK_JSON" RETURN_VAL
		done	
	fi
	
	# do nothing right now
	if [ "$STORY_STATE" == "STARTED" ]; then
		log "Performing actions on story $1 with state $STORY_STATE" 1
	fi
	
	# moving to user2 and move all tasks to user2
	if [ "$STORY_STATE" == "PENDING" ]; then
		log "Performing actions on story $1 with state $STORY_STATE" 1
		local STORY_JSON='{"storyId": '$1',"usersChanged": true, "userIds": ['$USER2_ID']}'
		agilefant-API-storeStory "$STORY_JSON" RETURN_VAL
		local d
		for d in $(seq 1 "$STORY_TASKS_COUNT");
		do
			local TASK_ID=$(echo "$2" | jq --arg D $d '. | .tasks[$D | tonumber -1].id')
			
			local TASK_JSON='{"taskId": '$TASK_ID', "responsiblesChanged": true,  "newResponsibles": ['$USER2_ID']}'
			agilefant-API-storeTask "$TASK_JSON" RETURN_VAL
		done

	fi
	
	# do nothing right now
	if [ "$STORY_STATE" == "BLOCKED" ]; then
		log "Performing actions on story $1 with state $STORY_STATE" 1
	fi
	
	# move story to user1, if all tasks are ready then mark story and all tasks done, if not mark story deferred
	if [ "$STORY_STATE" == "IMPLEMENTED" ]; then
		log "Performing actions on story $1 with state $STORY_STATE" 1
		#move ready to user1
			# check if all tasks are ready
				# if yes, mark story done and all tasks done and user1
				# if not, mark story "deferred" and move user1
				
		log "Performing actions on story $1 with state $STORY_STATE" 1
		
		local allReady=1
		local e
		for e in $(seq 1 "$STORY_TASKS_COUNT");
		do
		
		#echo "XXXXXXXXXX: $2"
		
			local TASK_STATE=$(echo "$2" | jq -r --arg E $e '. | .tasks[$E | tonumber -1].data.state')
			
			echo "TASK STATE = $TASK_STATE"			
			
			if [ ! "$TASK_STATE" == "IMPLEMENTED" ]; then
				if [ ! "$TASK_STATE" == "DONE" ]; then
					local allReady=0
				fi
			fi
			
		done		
		if [ "$allReady" == "1" ]; then 
			local STORY_JSON='{"storyId": '$1',"usersChanged": true, "userIds": ['$USER1_ID'], "story.state": "DONE"}'
			agilefant-API-storeStory "$STORY_JSON" RETURN_VAL
			local f
			for f in $(seq 1 "$STORY_TASKS_COUNT");
			do
				local TASK_ID=$(echo "$2" | jq --arg F $f '. | .tasks[$F | 	tonumber -1].id')
				local TASK_JSON='{"taskId": '$TASK_ID', "responsiblesChanged": true,  "newResponsibles": ['$USER1_ID'], "task.state": "DONE", "task.effortLeft": 0}'
				agilefant-API-storeTask "$TASK_JSON" RETURN_VAL
			done
		else 
			local STORY_JSON='{"storyId": '$1',"usersChanged": true, "userIds": ['$USER1_ID'], "story.state": "DEFERRED"}'
			agilefant-API-storeStory "$STORY_JSON" RETURN_VAL
			local g
			for g in $(seq 1 "$STORY_TASKS_COUNT");
			do
				local TASK_ID=$(echo "$2" | jq --arg G $g '. | .tasks[$G | 	tonumber -1].id')
				local TASK_JSON='{"taskId": '$TASK_ID', "responsiblesChanged": true,  "newResponsibles": ['$USER1_ID']}'
				agilefant-API-storeTask "$TASK_JSON" RETURN_VAL
			done
		fi
			
				
	fi
	
	# move story to user1
	if [ "$STORY_STATE" == "DONE" ]; then
		log "Performing actions on story $1 with state $STORY_STATE" 1
		local STORY_JSON='{"storyId": '$1',"usersChanged": true, "userIds": ['$USER1_ID']}'
		agilefant-API-storeStory "$STORY_JSON" RETURN_VAL
		
	fi
	
	# move story to user1
	if [ "$STORY_STATE" == "DEFERRED" ]; then
		log "Performing actions on story $1 with state $STORY_STATE" 1
		local STORY_JSON='{"storyId": '$1',"usersChanged": true, "userIds": ['$USER1_ID']}'
		agilefant-API-storeStory "$STORY_JSON" RETURN_VAL
		
	fi
	#ALL#
	# mark story blocked if one task is blocked, assign both users
	local blocked=0
	local h
	for h in $(seq 1 "$STORY_TASKS_COUNT");
	do
		local TASK_STATE=$(echo "$2" | jq -r --arg H $h '. | .tasks[$H | tonumber -1].data.state')
		if [ "$TASK_STATE" == "BLOCKED" ]; then
			local blocked=1
		fi
	done	
	if [ "$blocked" == "1" ]; then
		log "Story $1 with state $STORY_STATE das BLOCKED task! Marking story blocked" 1
		local STORY_JSON='{"storyId": '$1',"usersChanged": true, "userIds": ['$USER1_ID', '$USER2_ID'], "story.state": "BLOCKED"}'
		agilefant-API-storeStory "$STORY_JSON" RETURN_VAL
	fi
		
}

SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log 101
log 10

source $DIR/agilefant-API/agilefant-API-tools.sh

agilefant-API-login

agilefant-API-getMainStructure MAIN_JSON

agilefant-API-execForAll "$MAIN_JSON" "" "" "" "callbackStory" ""

agilefant-API-logout

log 11
log 101
exit 0