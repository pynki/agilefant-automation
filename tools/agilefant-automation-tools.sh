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


#TODO BIG ONE: build helper function to read out the data of objects from the JSON build in mainstructure script. get main struct reads into a var, that var is passed and then the data returned. the id of the data wanted is passed to. like this: getProjectDataFromTree($project_id $tree)

#TODO get all objects of a type with their data, return json
#TODO get all objects of a type that meet specific requirements, return json.this is a massive filtering system. need to think carefully about what filters are needed. genereic filters with jq?  

#TODO all the setter for the objects!
#TODO all the creators for the objects!
export -f agilefant-automation-login
export -f agilefant-automation-logout
export -f agilefant-automation-getMenuData
export -f agilefant-automation-getProjectStoryTree
export -f agilefant-automation-getStory
export -f agilefant-automation-getProduct
export -f agilefant-automation-getProject
export -f agilefant-automation-getProjectTotalSpentEffort
export -f agilefant-automation-getIteration
export -f agilefant-automation-getTask
export -f agilefant-automation-getUsers
