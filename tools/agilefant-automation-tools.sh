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
