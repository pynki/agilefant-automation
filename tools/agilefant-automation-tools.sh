#!/bin/bash

#TODO comment calls
#TODO check the cookie file every fucking time

agilefant-automation-login() {
	log "Logging into agilefant" 1
	if [ ! -d "$COOKIE_FILE_DIR" ]; then
		log "COOKIE_FILE_DIR ${COOKIE_FILE_DIR} does not exist. Creating it." 1
		mkdir $COOKIE_FILE_DIR
	fi
	local CURL_OUTPUT
	CURL_OUTPUT=$(curl -ivLs --cookie "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --cookie-jar "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --data "j_username=$AGILEFANT_USER&j_password=$AGILEFANT_PASSWD" --location "${AGILEFANT_HOST}:${AGILEFANT_PORT}${AGILEFANT_PATH}/j_spring_security_check" 2>&1)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
	log "Logged into agilefant" 1
#TODO check here if we are reallt logged in
}

agilefant-automation-logout() {
	log "Logging out of agilefant" 1
    if [ ! -d "$COOKIE_FILE_DIR" ]; then
         log "COOKIE_FILE_DIR does not exist. Cannot logout." 1
         return 1     
	fi	
	local CURL_OUTPUT
     CURL_OUTPUT=$(curl -ivLs --cookie "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --cookie-jar "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --data "j_username=$AGILEFANT_USER&j_password=$AGILEFANT_PASSWD" --location "${AGILEFANT_HOST}:${AGILEFANT_PORT}${AGILEFANT_PATH}/j_spring_security_logout?exit=Logout" 2>&1)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
	log "Logged out of agilefant" 1
	if [ $CLEANUP_TMP_DIR == 1 ]; then
		rm -r $COOKIE_FILE_DIR
		log "Cleaned up COOKIE_FILE_DIR - well, just removed it..." 1
	fi
#TODO check if we are logged out
}

### from here on: this needs bash 4.3!!!
# call agilefant-automation-getMenuData $RETURN_VAR
agilefant-automation-getMenuData() {
	log "Getting agilefant menuData" 1
	declare -n reVal=$1
	local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/menuData.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0 
}

# call agilefant-automation-getProjectStoryTree $RETURN_VAL $PROJECT_BACKLOG_ID
agilefant-automation-getProjectStoryTree() {
	log "Getting projectStoryTree of project with backlogId: $2" 1
	declare -n reVal=$1
	local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "projectId=$2" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/getProjectStoryTree.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-getStory $RETURN_VAL $STORY_ID
agilefant-automation-getStory() {
	log "Getting story with id $2" 1
	declare -n reVal=$1
	local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/retrieveStory.action?storyId=$2)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-getProduct $RETURN_VAL $PRODUCT_BACKLOG_ID
agilefant-automation-getProduct() {
    log "Getting product with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/retrieveProduct.action?productId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-getProject $RETURN_VAL $PROJECT_BACKLOG_ID
agilefant-automation-getProject() {
    log "Getting project with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/projectData.action?projectId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-getProjectTotalSpentEffort $RETURN_VAL $PROJECT_BACKLOG_ID
agilefant-automation-getProjectTotalSpentEffort() {
    log "Getting total spend effort of project with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/projectTotalSpentEffort.action?projectId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# this gives us the tasks that have no story and belong to an iteration
# call agilefant-automation-getIteration $RETURN_VAL $ITERATION_BACKLOG_ID
agilefant-automation-getIteration() {
    log "Getting iteration with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/iterationData.action?iterationId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# this is a dirty hack - there is no getTaskData call as far as i could see
# call agilefant-automation-getTask $RETURN_VAL $TASK_ID
agilefant-automation-getTask() {
    log "Getting task with taskId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "taskId=$2" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeTask.action)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-getUsers $RETURN_VAL
agilefant-automation-getUsers() {
    log "Getting all users" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/retrieveAllUsers.action)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

###############################################################################

# call agilefant-automation-getProduct-simple $RETURN_VAL $ID
agilefant-automation-getProduct-simple() {
	log "Gettingproduct simple" 1
    declare -n reVal=$1
	
	agilefant-automation-getProduct GS_PRODUCT $2
	local GS_PRODUCT=$(echo $GS_PRODUCT | jq '. | del(.description) | del(.class) | del(.standAlone) | del(.product)')
	local GS_PRODUCT_JSON=$(echo $GS_PRODUCT | jq '. | {"id":.id, "type":0, "data": ., "projects": []}')
	
	local GS_JSON=$GS_PRODUCT_JSON
	
	reVal=$GS_JSON
    log "JSON is: $GS_JSON" 0
}

# call agilefant-automation-getProject-simple $RETURN_VAL $ID
agilefant-automation-getProject-simple() {
	log "Getting project simple" 1
    declare -n reVal=$1
	
	agilefant-automation-getProject GS_PROJECT $2
	local GS_PROJECT=$(echo $GS_PROJECT | jq '. | del(.class) | del(.description) | del(.children) | del(.leafStories) | del(.product) | del(.rank) | del(.root) | del(.standAlone) | del(.status)')
	local GS_PROJECT_JSON=$(echo $GS_PROJECT | jq '. | {"id": .id, "type":1, "users": [], "data": ., "stories": [], "iterations": []}')
	local GS_PROJECT_ASSIGNEES_COUNT=$(echo $GS_PROJECT | jq '. | .assignees | length')
	for gs_i in $(seq 1 "$GS_PROJECT_ASSIGNEES_COUNT");
	do
        local GS_PROJECT_ASSIGNEE=$(echo $GS_PROJECT | jq -r --arg I $gs_i '. | .assignees[$I | tonumber -1] | del(.class) | del(.initials)')
        local GS_PROJECT_JSON=$(echo $GS_PROJECT_JSON | jq -r --arg I $gs_i --arg A "$GS_PROJECT_ASSIGNEE" '. | .users[$I | tonumber -1] |= . + ($A | fromjson)')

        local GS_PROJECT_JSON=$(echo $GS_PROJECT_JSON | jq '. | del(.data.assignees)')
	done
	
	local GS_JSON=$GS_PROJECT_JSON
	
	reVal=$GS_JSON
    log "JSON is: $GS_JSON" 0
}

# call agilefant-automation-getIteration-simple $RETURN_VAL $ID
agilefant-automation-getIteration-simple() {
	log "Getting iteration simple" 1
    declare -n reVal=$1
	
	agilefant-automation-getIteration GS_ITERATION $2
	local GS_ITERATION=$(echo $GS_ITERATION | jq '. | del(.class) | del(.tasks) | del(.description) | del(.rankedStories) | del(.root) |  del(.product) | del(.readonlyToken) | del(.iterationMetrics) ')
	local GS_ITERATION_JSON=$(echo $GS_ITERATION | jq '. | {"id": .id, "type": 2, "users": [], "data": ., "tasks": [], "stories":[]}')
	local GS_ITERATION_ASSIGNEES_COUNT=$(echo $GS_ITERATION | jq '. | .assignees | length')
	for gs_i in $(seq 1 "$GS_ITERATION_ASSIGNEES_COUNT");
	do
		local GS_ITERATION_ASSIGNEE=$(echo $GS_ITERATION | jq -r --arg I $gs_i '. | .assignees[$I | tonumber -1] | del(.class) | del(.initials)')
		local GS_ITERATION_JSON=$(echo $GS_ITERATION_JSON | jq -r --arg I $gs_i --arg A "$GS_ITERATION_ASSIGNEE" '. | .users[$I | tonumber -1] |= . + ($A | fromjson)')
        local GS_ITERATION_JSON=$(echo $GS_ITERATION_JSON | jq '. | del(.data.assignees)')
	done
	
	local GS_JSON=$GS_ITERATION_JSON
	
	reVal=$GS_JSON
    log "JSON is: $GS_JSON" 0
}

# call agilefant-automation-getStory-simple $RETURN_VAL $ID
agilefant-automation-getStory-simple() {
	log "Getting story simple $2" 1
    declare -n reVal=$1
	
	agilefant-automation-getStory GS_STORY $2

	local GS_STORY=$(echo $GS_STORY | jq '. | del(.backlog) | del(.class) | del(.children) | del(.description) | del(.highestPoints) | del(.metrics) | del(.tasks) | del(.treeRank) | del(.workQueueRank) | del(.labels)')
	local GS_STORY_PARENT=$(echo $GS_STORY | jq '. | .parent.id')
	if [ $GS_STORY_PARENT == "null" ]; then
		GS_STORY_PARENT="-1"
	fi

	local GS_STORY=$(echo $GS_STORY | jq '. | del(.parent)')
	local GS_STORY_JSON=$(echo $GS_STORY | jq --arg P "$GS_STORY_PARENT" '. | {"id": .id, "type": 3, "parent": ($P | tonumber -1),"users":[], "iteration": .iteration.id, "data": ., "tasks":[]}')
	local GS_STORY_RESPONSIBLES_COUNT=$(echo $GS_STORY | jq '. | .responsibles | length')
	for gs_i in $(seq 1 "$GS_STORY_RESPONSIBLES_COUNT");
	do
		local GS_STORY_RESPONSIBLE=$(echo $GS_STORY | jq -r --arg I $gs_i '. | {"id": (.responsibles[$I | tonumber -1] | .id), "name":  (.responsibles[$I | tonumber -1] | .name)}')
		local GS_STORY_JSON=$(echo $GS_STORY_JSON | jq -r --arg I $gs_i --arg A "$GS_STORY_RESPONSIBLE" '. | .users[$I | tonumber -1] |= . + ($A | fromjson)')
		 local GS_STORY_JSON=$(echo $GS_STORY_JSON | jq '. | del(.data.responsibles) | del(.data.iteration)')
	done
	
	local GS_JSON=$GS_STORY_JSON
	
	reVal=$GS_JSON
    log "JSON is: $GS_JSON" 0
}

# call agilefant-automation-getTask-simple $RETURN_VAL $ID
agilefant-automation-getTask-simple() {
	log "Getting task simple" 1
    declare -n reVal=$1
	
	agilefant-automation-getTask GS_TASK $2
	local GS_TASK=$(echo $GS_TASK | jq '. | del(.class) | del(.rank) | del(.description) | del(.rank)')
	local GS_TASK_JSON=$(echo $GS_TASK | jq '. | {"id": .id, "type": 4, "users":[], "data": .}')
	local GS_TASK_RESPONSIBLES_COUNT=$(echo $GS_TASK | jq '. | .responsibles | length')
	for gs_i in $(seq 1 "$GS_TASK_RESPONSIBLES_COUNT");
	do
		local GS_TASK_RESPONSIBLE=$(echo $GS_TASK | jq -r --arg I $gs_i '. | {"id": (.responsibles[$I | tonumber -1] | .id), "name":  (.responsibles[$I | tonumber -1] | .name)}')
		local GS_TASK_JSON=$(echo $GS_TASK_JSON | jq -r --arg I $gs_i --arg A "$GS_TASK_RESPONSIBLE" '. | .users[$I | tonumber -1] |= . + ($A | fromjson)')
		local GS_TASK_JSON=$(echo $GS_TASK_JSON | jq '. | del(.data.responsibles) | del(.data.iteration)')
	done
	
	local JSON=$GS_TASK_JSON
	
	reVal=$JSON
    log "JSON is: $GS_JSON" 0
}
# call agilefant-automation-getMainStructure $RETURN_VAL 
agilefant-automation-getMainStructure() {
	log "Getting main structure" 1
    declare -n reVal=$1
	MAIN_JSON='{"products": [], "users": []}'
	agilefant-automation-getMenuData MENU_DATA
	MAIN=$(echo $MENU_DATA | jq -r '[.[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {class: .addClass, id: .id, title: .title})]})]}]')
	PRODUCT_COUNT="$(echo $MAIN | jq '. | length')"
	log "PRODUCT_COUNT is: $PRODUCT_COUNT" 1
	for i in $(seq 1 "$PRODUCT_COUNT"); 
	do
		PRODUCT="$(echo $MAIN | jq -r --arg I $i '.[$I | tonumber -1]')"
		PRODUCT_ID=$(echo $PRODUCT | jq '. | .id')
		log "Working on product with id: $PRODUCT_ID" 1
		if [ ! "$PRODUCT_ID" == "-1" ]; then
			agilefant-automation-getProduct-simple X_PRODUCT $PRODUCT_ID
		else
			X_PRODUCT='{"id": -1, "type": 0, "iterations":[]}'
		fi
		PRODUCT_CHILD_COUNT="$(echo $PRODUCT | jq '. | .childs | length')"
		log "PRODUCT_CHILD_COUNT is $PRODUCT_CHILD_COUNT" 1
		for j in $(seq 1 "$PRODUCT_CHILD_COUNT");
		do
			PROJECT_OR_ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .type')
			BACKLOG_ID=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .id')
			if [ "$PROJECT_OR_ITERATION" == "PROJECT" ]; then
				log "Working on project with id: $BACKLOG_ID" 1
				agilefant-automation-getProject-simple X_PROJECT $BACKLOG_ID
				PROJECT_ITERATION_COUNT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .childs | length')
				log "Number of project iterations:  $PROJECT_ITERATION_COUNT" 1
				PROJECT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
				for k in $(seq 1 "$PROJECT_ITERATION_COUNT"); 
				do
					ITERATION=$(echo $PRODUCT | jq -r --arg J $j --arg K $k '. | .childs[$J | tonumber -1] | .childs[$K | tonumber -1]') 
					ITERATION_ID=$(echo $ITERATION | jq '. | .id')
					agilefant-automation-getIteration ITERATION_JSON  $ITERATION_ID
					agilefant-automation-getIteration-simple X_ITERATION $ITERATION_ID
					ITERATION_TASKS_COUNT=$(echo $ITERATION_JSON | jq '. | .tasks | length')
					for x in $(seq 1 "$ITERATION_TASKS_COUNT");
					do
						TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
						log "Working on task with ID: $TASK_ID" 1
						agilefant-automation-getTask-simple X_TASK $TASK_ID
						X_ITERATION=$(echo $X_ITERATION | jq --arg Z $x --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')	
					done
					X_PROJECT=$(echo $X_PROJECT | jq --arg K $k --arg X "$X_ITERATION" '. | .iterations[$K | tonumber -1] |= .+ ($X | fromjson)')
				done
				agilefant-automation-getProjectStoryTree PROJECT_STORY_TREE $BACKLOG_ID	
				PROJECT_STORIES=$(echo $PROJECT_STORY_TREE | grep -o -E "storyid\S+" | grep -o "[0-9]*")
				count=1
				while read -ra STORIES; do
					for l in "${STORIES[@]}"; do
						log "Working on story with id: $l" 1
						agilefant-automation-getStory-simple X_STORY $l
						agilefant-automation-getStory STORY_TASKS $l
						STORY_TASKS_COUNT=$(echo $STORY_TASKS | jq -r '. | .tasks | length')
						for z in $(seq 1 "$STORY_TASKS_COUNT");
						do
							TASK_ID=$(echo $STORY_TASKS | jq --arg Z $z '. | .tasks[$Z | tonumber -1] | .id')
							log "Working on task: $TASK_ID" 1
							agilefant-automation-getTask-simple X_TASK $TASK_ID
							X_STORY=$(echo $X_STORY | jq --arg Z $z --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
						done
					done
					X_PROJECT=$(echo $X_PROJECT | jq --arg L "$count" --arg X "$X_STORY" '. | .stories[$L | tonumber -1] |= .+ ($X | fromjson)')
					count=$(($count+1))
				done <<< "$PROJECT_STORIES"
				X_PRODUCT=$(echo $X_PRODUCT | jq --arg J $j --arg X "$X_PROJECT" '. | .projects[$J | tonumber -1] |= .+ ($X | fromjson)')
			fi
			if [ "$PROJECT_OR_ITERATION" == "ITERATION" ]; then
				ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
				log "Working on iteration with id: $BACKLOG_ID" 1
				agilefant-automation-getIteration-simple X_ITERATION $BACKLOG_ID
				ITERATION_ID=$(echo $ITERATION | jq '. | .id')
				agilefant-automation-getIteration ITERATION_JSON  $ITERATION_ID
				ITERATION_TASKS_COUNT=$(echo $ITERATION_JSON | jq '. | .tasks | length')
				ITERATION_STORY_COUNT=$(echo $ITERATION_JSON | jq '. | .rankedStories | length')
				for f in $(seq 1 "$ITERATION_STORY_COUNT");
				do
					STORY_ID=$(echo $ITERATION_JSON | jq --arg F $f '. | .rankedStories[$F | tonumber -1].id')
					agilefant-automation-getStory-simple X_STORY $STORY_ID
					agilefant-automation-getStory STORY_TASKS $STORY_ID
					STORY_TASKS_COUNT=$(echo $STORY_TASKS | jq -r '. | .tasks | length')
					for z in $(seq 1 "$STORY_TASKS_COUNT");
					do
						TASK_ID=$(echo $STORY_TASKS | jq --arg Z $z '. | .tasks[$Z | tonumber -1] | .id')
						log "Working on task: $TASK_ID" 1
						agilefant-automation-getTask-simple X_TASK $TASK_ID
						X_STORY=$(echo $X_STORY | jq --arg Z $z --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
					done
					X_ITERATION=$(echo $X_ITERATION | jq --arg L "$f" --arg X "$X_STORY" '. | .stories[$L | tonumber -1] |= .+ ($X | fromjson)')
				done
				for x in $(seq 1 "$ITERATION_TASKS_COUNT");
				do
					TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
					log "Working on task with ID: $TASK_ID" 1
					agilefant-automation-getTask-simple X_TASK $TASK_ID
					X_ITERATION=$(echo $X_ITERATION | jq --arg Z $x --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
				done
				X_PRODUCT=$(echo $X_PRODUCT | jq --arg J $j --arg X "$X_ITERATION" '. | .iterations[$J | tonumber -1] |= .+ ($X | fromjson)')	
			fi
		done
		MAIN_JSON=$(echo $MAIN_JSON | jq --arg I "$i" --arg X "$X_PRODUCT" '. | .products[ $I | tonumber -1] |= .+ ($X | fromjson)')
	done
	agilefant-automation-getUsers USERS
	USERS_COUNT=$(echo $USERS | jq '. | length')
	for i in $(seq 1 "$USERS_COUNT");
	do
		USER=$(echo $USERS | jq --arg I $i '.[($I | tonumber -1)] | del(.class)')
		MAIN_JSON=$(echo $MAIN_JSON | jq --arg I $i --arg U "$USER" '. | .users[($I | tonumber -1)] |= .+ ($U | fromjson)')
	done	
	reVal=$MAIN_JSON
	log "MAIN_JSON is: $MAIN_JSON" 0
}