#!/bin/bash

# call agilefant-automation-createQueryFromJson $RETURN_QUERY $JSON
agilefant-automation-createQueryFromJson() {
	log "Creating query from json" 1
	declare -n reVal=$1	
	QUERY=""
	ARR=( $(echo "$2" | jq -r 'keys[]') )
	FIRST="true"
	for key in "${ARR[@]}";				
	do	
		if [ "$FIRST" == "false" ]; then
			QUERY=${QUERY}"&"
		else
			FIRST="false"
		fi
		VALUE=$(echo "$2" | jq --arg KEY $key '. | .[$KEY]')		
		IS_ARR=$(echo "$VALUE" | jq 'if type=="array" then true else false end')
		VALUE=$(echo "$VALUE" | jq -r '.')
		if [ "$IS_ARR" == "true" ]; then
			ARR_LENGTH=$(echo "$VALUE" | jq '. | length')
			for i in $(seq 1 "$ARR_LENGTH");
			do
				ARR_VALUE=$(echo $VALUE | jq --arg I $i '. | .[$I | tonumber -1]')
				if [ $i -gt 1 ]; then
				QUERY=${QUERY}"&"
				fi
				QUERY=${QUERY}"$key=$ARR_VALUE"
			done
		else 
			QUERY=${QUERY}"$key=$VALUE"
		fi
	done	
	reVal=$QUERY
	log "QUERY is: $QUERY" 0
}

###############################################################################

# call agilefant-automation-login
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

# call agilefant-automation-logout
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

###############################################################################

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

# call agilefant-automation-getIteration $RETURN_VAL $ITERATION_BACKLOG_ID
# this gives us the tasks that have no story and belong to an iteration
agilefant-automation-getIteration() {
    log "Getting iteration with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/iterationData.action?iterationId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-getTask $RETURN_VAL $TASK_ID
# this is a dirty hack - there is no getTaskData call as far as i could see
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
	log "Getting product simple" 1
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
# function to create a simple representation of the agilefant object structure (products, projects, iterations, stories, tasks)
# it cuts out crosslinks between objects (except for stories with parents) and leaves out text heavy fields like descriptions
# this funtion is meant to give a json representation of all agilefant objects to run searches and other operations on
# see the agilefant-automation-ExecForAll function below for an example on how to iterate over the structure this funtion creates
agilefant-automation-getMainStructure() {
	log "Getting main structure" 1
    declare -n reVal=$1
	MAIN_JSON='{"products": [], "users": []}'
	agilefant-automation-getMenuData MENU_DATA
	MAIN=$(echo $MENU_DATA | jq -r '[.[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {class: .addClass, id: .id, title: .title})]})]}]')
	PRODUCT_COUNT="$(echo $MAIN | jq '. | length')"
	log "PRODUCT_COUNT is: $PRODUCT_COUNT" 0
	for i in $(seq 1 "$PRODUCT_COUNT"); 
	do
		PRODUCT="$(echo $MAIN | jq -r --arg I $i '.[$I | tonumber -1]')"
		PRODUCT_ID=$(echo $PRODUCT | jq '. | .id')
		log "Working on product with id: $PRODUCT_ID" 0
		if [ ! "$PRODUCT_ID" == "-1" ]; then
			agilefant-automation-getProduct-simple X_PRODUCT $PRODUCT_ID
		else
			X_PRODUCT='{"id": -1, "type": 0, "iterations":[]}'
		fi
		PRODUCT_CHILD_COUNT="$(echo $PRODUCT | jq '. | .childs | length')"
		log "PRODUCT_CHILD_COUNT is $PRODUCT_CHILD_COUNT" 0
		for j in $(seq 1 "$PRODUCT_CHILD_COUNT");
		do
			PROJECT_OR_ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .type')
			BACKLOG_ID=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .id')
			if [ "$PROJECT_OR_ITERATION" == "PROJECT" ]; then
				log "Working on project with id: $BACKLOG_ID" 0
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
						log "Working on story with id: $l" 0
						agilefant-automation-getStory-simple X_STORY $l
						agilefant-automation-getStory STORY_TASKS $l
						STORY_TASKS_COUNT=$(echo $STORY_TASKS | jq -r '. | .tasks | length')
						for z in $(seq 1 "$STORY_TASKS_COUNT");
						do
							TASK_ID=$(echo $STORY_TASKS | jq --arg Z $z '. | .tasks[$Z | tonumber -1] | .id')
							log "Working on task: $TASK_ID" 0
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
				log "Working on iteration with id: $BACKLOG_ID" 0
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
						log "Working on task: $TASK_ID" 0
						agilefant-automation-getTask-simple X_TASK $TASK_ID
						X_STORY=$(echo $X_STORY | jq --arg Z $z --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
					done
					X_ITERATION=$(echo $X_ITERATION | jq --arg L "$f" --arg X "$X_STORY" '. | .stories[$L | tonumber -1] |= .+ ($X | fromjson)')
				done
				for x in $(seq 1 "$ITERATION_TASKS_COUNT");
				do
					TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
					log "Working on task with ID: $TASK_ID" 0
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
	log "Got main structure" 1
}

###############################################################################

# call agilefant-automation-createProject $PROJECT_JSON $RETURN_VAL $NEW_ID
# $PROJECT_JSON should look like:
# '{"teamsChanged": true, "product.name": "PRODUCT555555555", "product.description": "DESCRIPTION", "teamIds": [2,3]}'
# set "teamsChanged" to != true for no team access
agilefant-automation-createProduct() {
	log "Creating product" 1		
	declare -n reVal=$2
	declare -n reId=$3
	
	agilefant-automation-createQueryFromJson CURL_DATA "$1"
	
	#CURL_DATA=${CURL_DATA}"&product.name="$(echo $1 | jq -r '. | .name')
	#CURL_DATA=${CURL_DATA}"&product.description="$(echo $1 | jq -r '. | .description')	
	#TEAMS_CHANGED=$(echo $1 | jq -r '. | .teamsChanged')
	#CURL_DATA=${CURL_DATA}"&teamsChanged="$TEAMS_CHANGED
	#if [ "$TEAMS_CHANGED" == "true" ]; then
	#	TEAM_COUNT=$(echo $1 | jq '. | .teamIds | length')
	#	for i in $(seq 1 "$TEAM_COUNT");
	#	do
	#		CURL_DATA=${CURL_DATA}"&teamIds="$(echo $1 | jq --arg I $i '. | #.teamIds[$I | tonumber -1]')
	#	done
	#fi
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeNewProduct.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-createProject $PRODUCT_JSON $RETURN_VAL $NEW_ID
# $PRODUCT_JSON should look like:
# '{"productId": 69, "project.startDate": 1503964800000, "project.endDate": 1505210400000, "assigneesChanged": true,"project.name": "555555555", "project.description": "DESCRIPTION", "assigneeIds": [5,3], "project.backlogSize": "5h", "project.baselineLoad": "6h", "project.status": "BLACK"}'
# set "assigneesChanged" to != true for no assignees
# set status to one of: "GREEN", "YELLOW", "RED", "GREY", "BLACK", default is "GREEN"
# "backlogSize", "baselineLoad" and "status" can be blank, they are not in the original creation call for projects (http://10.254.0.33:8080/ajax/storeNewProject.action) but in the change iteration call (http://10.254.0.33:8080/ajax/storeProject.action), but they can be set on project creation as well
agilefant-automation-createProject() {
	declare -n reVal=$2
	declare -n reId=$3
	agilefant-automation-createQueryFromJson CURL_DATA "$1"
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeNewProject.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-createIteration $ITERATION_JSON $RETURN_VAL $NEW_ID
# $ITERATION_JSON should look like:
# '{"iteration.startDate": 1503964800000, "iteration.endDate": 1505210400000, "assigneesChanged": true,"iteration.name": "ITERATION1111111111111111", "iteration.description": "DESCRIPTION", "teamsChanged": true, "assigneeIds": [5,3], "teamIds": [2,3],"iteration.backlogSize": "5h", "iteration.baselineLoad": "6h"}'
# do not set "parentBacklogId" for standalone iteration
# set "assigneesChanged" to != true for no assignees
# set "teamsChanged" to != true for no team access, only for standalone iterations neccessary
# "backlogSize" and "baselineLoad" can be blank, they are not in the original creation call for iterations (http://10.254.0.33:8080/ajax/storeNewIteration.action) but in the change iteration call (http://10.254.0.33:8080/ajax/storeIteration.action), but they can be set on iteration creation as well
agilefant-automation-createIteration() {
	declare -n reVal=$2
	declare -n reId=$3
	log "Creating iteration" 1
	agilefant-automation-createQueryFromJson CURL_DATA "$1"
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeNewIteration.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-createStory $STORY_JSON $RETURN_VAL $NEW_ID
# $STORY_JSON should look like:
# '{"backlogId": 72, "iteration": 71, "usersChanged": true, "story.name": "11111111111111111111111", "story.description": "DESCRIPTION", "userIds": [5,3], "story.storyValue": 1, "story.storyPoints": 2, "story.state": "NOT_STARTED"}'
# backlogId/iteration must be one of the following combinations:
#	targeting project without iteration: "backlogId"=iteration_backlog_id / "iteration"="" (empty string)
#	targeting iteration in project: {backlogId=iteration_backlog_id / "iteration"=iteration_backlog_id} or {backlogId=project_backlog_id / "iteration"=iteration_backlog_id} 
#	targeting standalone iteration: {"backlogId"=iteration_backlog_id / "iteration"=iteration_backlog_id}
# 	if "iteration" is set its only important is that backlogId is set to an existing backlog (no matter if project, iteration or product!) even a {"itaration"=iteration_backlog_id1 / "iteration"=iteration_backlog_id2} works. it will palce the story in the iteration with iteration_backlog_id2
# set "usersChanged" to != true for no users
# set "status" to one of: "NOT_STARTED", "STARTED" (aka 'In Progress'), "PENDING", "BLOCKED", "IMPLEMENTED" (aka 'Ready'), "DONE", "DEFERRED"
agilefant-automation-createStory() {
	declare -n reVal=$2
	declare -n reId=$3
	log "Creating story" 1		
	agilefant-automation-createQueryFromJson CURL_DATA "$1"	
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/createStory.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0	
}


# call agilefant-automation-createTask $TASK_JSON $RETURN_VAL $NEW_ID
# $TASK_JSON should look like:
#'{"storyId": 19, "responsiblesChanged": true, "name": "TASK1", "description": "DESCRIPTION", "newResponsibles": [5,3], "state": "NOT_STARTED"}'
# "storyId" does not need to be a 'LeafStory'
# set "state" to one of: "NOT_STARTED", "STARTED" (aka 'In Progress'), "PENDING", "BLOCKED", "IMPLEMENTED" (aka 'Ready'), "DONE", "DEFERRED"
agilefant-automation-createTask() {
	declare -n reVal=$2
	declare -n reId=$3
	log "Creating task" 1		
	agilefant-automation-createQueryFromJson CURL_DATA "$1"
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/createTask.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

###############################################################################

# call agilefant-automation-storeProduct $PRODUCT_JSON $RETURN_VAL
# $PRODUCT_JSON should look like: 
# '{"productId": 67,"teamsChanged": true, "product.name": "PRODUCT-NAME", "product.description": "DESCRIPTION", "teamIds": [2,3]}'
# as soon as a key/value pair is given it will be changed
# "productId" must be provided
# "teamsChanged" == true without "teamIds" array will remove access for all teams
agilefant-automation-storeProduct() {
	log "Storeing product" 1
	declare -n reVal=$2
	agilefant-automation-createQueryFromJson CURL_DATA "$1"
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeProduct.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-storeProject $PROJECT_JSON $RETURN_VAL
# $PRODUCT_JSON should look like: 
# '{"projectId": 80, "project.startDate": 1703964845678, "project.endDate": 1705210445678, "assigneesChanged": true,"project.name": "STORE_PROJECT1", "project.description": "1DESCRIPTION", "assigneeIds": [5,3], "project.backlogSize": "33h", "project.baselineLoad": "33h", "project.status": "BLACK"}'
# as soon as a key/value pair is given it will be changed
# "projectId" must be provided
# "teamsChanged" == true without "teamIds" array will remove access for all teams, same for "assigneesChanged" == true
# set status to one of: "GREEN", "YELLOW", "RED", "GREY", "BLACK"
agilefant-automation-storeProject() {
	log "Storeing project" 1
	declare -n reVal=$2
	agilefant-automation-createQueryFromJson CURL_DATA "$1"
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeProject.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-storeIteration $ITERATION_JSON $RETURN_VAL
# $ITERATION_JSON should look like:
# '{"iterationId": 78, "iteration.startDate": 1703964800000, "iteration.endDate": 1705210400000, "assigneesChanged": true, "iteration.name": "ITERATION", "iteration.description": "DESCRIPTION", "assigneeIds": [5,3],"iteration.backlogSize": "5h", "iteration.baselineLoad": "6h", "teamsChanged": true, "teamIds": [3]}'
# "iterationId" must be provided
# set "assigneesChanged" to != true for no assignees
# set "teamsChanged" to != true for no team access, only for standalone iterations neccessary
# both "iteration.assigneesChanged" and "assigneesChanged" need to be true to have an effect
# ATTENTION: the result when removing an assignee is flawed. the result is false, thats why we run the call twice to get the right result!
agilefant-automation-storeIteration() {
	log "Storeing project" 1
	declare -n reVal=$2
	agilefant-automation-createQueryFromJson CURL_DATA "$1"
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeIteration.action)
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeIteration.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 1
}

# call agilefant-automation-storeStory $STORY_JSON $RETURN_VAL
# $STORY_JSON should look like:
# '{"backlogId": 72, "iteration": 71, "usersChanged": true, "story.name": "11111111111111111111111", "story.description": "DESCRIPTION", "userIds": [5,3], "story.storyValue": 1, "story.storyPoints": 2, "story.state": "NOT_STARTED"}'
# "storyId" must be provided
# backlogId/iteration must be one of the following combinations:
#	targeting project without iteration: "backlogId"=iteration_backlog_id / "iteration"="" (empty string)
#	targeting iteration in project: {backlogId=iteration_backlog_id / "iteration"=iteration_backlog_id} or {backlogId=project_backlog_id / "iteration"=iteration_backlog_id} 
#	targeting standalone iteration: {"backlogId"=iteration_backlog_id / "iteration"=iteration_backlog_id}
# 	if "iteration" is set its only important is that backlogId is set to an existing backlog (no matter if project, iteration or product!) even a {"itaration"=iteration_backlog_id1 / "iteration"=iteration_backlog_id2} works. it will palce the story in the iteration with iteration_backlog_id2
# set "usersChanged" to != true for no users
# set "status" to one of: "NOT_STARTED", "STARTED" (aka 'In Progress'), "PENDING", "BLOCKED", "IMPLEMENTED" (aka 'Ready'), "DONE", "DEFERRED"
agilefant-automation-storeStory() {
	declare -n reVal=$2
	log "Creating story" 1		
	agilefant-automation-createQueryFromJson CURL_DATA "$1"	
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeStory.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0	
}

# call agilefant-automation-storeTask $TASK_JSON $RETURN_VAL
# $TASK_JSON should look like:
# '{"taskId": 58, "responsiblesChanged": true, "task.name": "XXXXXXXX", "task.description": "DESCRIPTION", "newResponsibles": [5,3], "task.state": "STARTED", "task.effortLeft": 123}'
# "taskId" must be provided
# set "responsiblesChanged" to != true for no responsibles
# set "state" to one of: "NOT_STARTED", "STARTED" (aka 'In Progress'), "PENDING", "BLOCKED", "IMPLEMENTED" (aka 'Ready'), "DONE", "DEFERRED"
agilefant-automation-storeTask() {
	log "Storeing task" 1
	declare -n reVal=$2
	agilefant-automation-createQueryFromJson CURL_DATA "$1"
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeTask.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

###############################################################################

# call agilefant-automation-deleteProduct $PRODUCT_BACKLOG_ID
agilefant-automation-deleteProduct() {
	log "Deleting product with id $1" 1
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "confirmationString=yes&productId=$1" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteProduct.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-deleteProject $PROJECT_BACKLOG_ID
agilefant-automation-deleteProject() {
	log "Deleting project with id $1" 1
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "confirmationString=yes&projectId=$1" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteProject.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-deleteIteration $ITERATION_BACKLOG_ID
agilefant-automation-deleteIteration() {
	log "Deleting iteration with id $1" 1
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "confirmationString=yes&iterationId=$1" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteIteration.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-deleteStory $STORY_ID $CHILD_HANDLING
# this has 3 cases:
#	1: story without parent and children
#	2: story that has children and no parent
#	3: story that has children and parent
# depending on the case there is more than one possible action
#	1: delete story
#	2: (1)delete with children / (2)delete and move children to root	
#	3: (1)delete with children / (2)delete and move children to parent
# $CHILD_HANDLING must be set as follows:
#	1: 	 $CHILD_HANDLING must be "DELETE" or "MOVE" see remark about default value
#	2.1: $CHILD_HANDLING == "DELETE"
#	2.2: $CHILD_HANDLING == "MOVE"
#	3.1: $CHILD_HANDLING == "DELETE"
#	3.2: $CHILD_HANDLING == "MOVE"
# if $CHILD_HANDLING is not explicitly set to "DELETE" this function sets it to "MOVE". Only "DELETE" or "MOVE" are accepted by the agilefant as values.
agilefant-automation-deleteStory() {
	log "Deleting story with id $1" 1
	CHILD_HANDLING=$2
	if [ ! $CHILD_HANDLING == "DELETE" ]; then
		CHILD_HANDLING="MOVE"
	fi		
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "storyId=$1&childHandlingChoice=$CHILD_HANDLING" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteStory.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-automation-deleteTask $TASK_ID
agilefant-automation-deleteTask() {
	log "Deleting task with id $1" 1
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "taskId=$1" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteTask.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

###############################################################################

# call agilefant-automation-ExecForAll $MAIN_JSON $PRODUCT_CALLBACK $PROJECT_CALLBACK $ITERATION_CALLBACK $STORY_CALLBACK $TASK_CALLBACK
# simple function to run functions on all objects
# calls callbacks with 3 args:
# callback OBJECT_ID OBJECT_JSON MAIN_JSON
# calls in this order: project-stories-tasks - project-stories - projects - iteration-story-tasks - iteration-stories - iteration-tasks - products
agilefant-automation-ExecForAll() {
MAIN_JSON=$1
	PRODUCTS=$(echo $MAIN_JSON | jq '. | .products')
	PRODUCT_COUNT=$(echo $MAIN_JSON | jq '. | .products | length')
	log "Number of products: $PRODUCT_COUNT" 0
	for i in $(seq 1 "$PRODUCT_COUNT");
	do
		PROJECTS="[]"
		ITERATIONS="[]"
		PRODUCT=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1]')
		PRODUCT_ID=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1].id')
		log "PRODUCT_ID: $PRODUCT_ID" 0
		PROJECTS=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1].projects')
		if [ $PRODUCT_ID == "-1" ]; then
			ITERATIONS=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1].iterations')
		else
			PROJECT_COUNT=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1].projects | length')
			log "Number of projects: $PROJECT_COUNT" 0
			for j in $(seq 1 "$PROJECT_COUNT");
			do
				STORIES=[]
				TASKS=[]
				PROJECT=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1]')
				PROJECT_ID=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1].id')
				log "PROJECT_ID: $PROJECT_ID" 0
				ITERATIONS=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .iterations')
				STORIES=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories')
				STORIES_COUNT=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories | length')
				log "Number of stories: $STORIES_COUNT" 0
				for l in $(seq 1 "$STORIES_COUNT");
				do
					STORY_ID=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1].id')
					log "STORY_ID: $STORY_ID" 0
					STORY=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1]')
					TASKS=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1] | .tasks')
					TASKS_COUNT=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1] | .tasks | length')
					log "Number of tasks: $TASKS_COUNT" 0
					for m in $(seq 1 "$TASKS_COUNT");
					do
						TASK_ID=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l --arg M $m '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1].id')
						log "TASK_ID: $TASK_ID" 0
						TASK=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l --arg M $m '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1]')
						$6 $TASK_ID $TASK $MAIN_JSON
					done
					$5 $STORY_ID $STORY $MAIN_JSON
				done
				$3 $PROJECT_ID $PROJECT $MAIN_JSON				
			done
		fi
		ITERATION_COUNT=$(echo $ITERATIONS | jq '. | length')
		log "Number of iterations: $ITERATION_COUNT" 0
		for k in $(seq 1 "$ITERATION_COUNT");
		do
			STORIES=[]
			TASKS=[]
			ITERATION=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1]')
			ITERATION_ID=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1].id')
			log "ITERATION_ID: $ITERATION_ID" 0
			STORIES=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .stories')
			STORIES_COUNT=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .stories | length')
			log "Number of stories: $STORIES_COUNT" 0
			for l in $(seq 1 "$STORIES_COUNT");
			do
				STORY_ID=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1].id')
				log "STORY_ID: $STORY_ID" 0
				STORY=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1]')
				TASKS=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks')
				TASKS_COUNT=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks | length')
				log "Number of tasks: $TASKS_COUNT" 0
				for m in $(seq 1 "$TASKS_COUNT");
				do
					TASK_ID=$(echo $ITERATIONS | jq --arg K $k --arg L $l --arg M $m '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1].id')
					log "TASK_ID: $TASK_ID" 0
					TASK=$(echo $ITERATIONS | jq --arg K $k --arg L $l --arg M $m '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1]')
					$6 $TASK_ID $TASK $MAIN_JSON
				done
				$5 $STORY_ID $STORY $MAIN_JSON
			done
			TASKS=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .tasks')
			TASKS_COUNT=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .tasks | length')
			log "Number of tasks: $TASKS_COUNT" 0
			for m in $(seq 1 "$TASKS_COUNT");
			do
				TASK_ID=$(echo $ITERATIONS | jq --arg K $k --arg M $m '. | .[$K | tonumber -1] | .tasks[$M | tonumber -1].id')
				log "TASK_ID: $TASK_ID" 0
				TASK=$(echo $ITERATIONS | jq --arg K $k --arg M $m '. | .[$K | tonumber -1] | .tasks[$M | tonumber -1]')
				$6 $TASK_ID $TASK $MAIN_JSON
			done
			$4 $ITERATION_ID $ITERATION $MAIN_JSON
		done
		$2 $PRODUCT_ID $PRODUCT $MAIN_JSON
	done
}