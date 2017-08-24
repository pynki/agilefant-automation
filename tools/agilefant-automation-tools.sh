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
	log "Logging out of agilefant" 1
	if [ $CLEANUP_TMP_DIR == 1 ]; then
		rm -r $COOKIE_FILE_DIR
		log "Cleaned up COOKIE_FILE_DIR" 1
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

# call agilefant-automation-getStory $RETURN_VAL $PROJECT_BACKLOG_ID $STORY_ID
agilefant-automation-getStory() {
	log "Getting story with id $3 from project with backlogId: $2" 1
	declare -n reVal=$1
	local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "projectId=$2" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/retrieveStory.action?storyId=$3)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

export -f agilefant-automation-login
export -f agilefant-automation-logout
export -f agilefant-automation-getMenuData
export -f agilefant-automation-getProjectStoryTree
export -f agilefant-automation-getStory
