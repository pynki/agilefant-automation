#!/bin/bash

agilefant-automation-login() {
	if [ ! -d "$COOKIE_FILE_DIR" ]; then
		echo "COOKIE_FILE_DIR does not exist. Creating it."
		mkdir $COOKIE_FILE_DIR
	fi
	local CURL_OUTPUT
	CURL_OUTPUT=$(curl -ivLs --cookie "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --cookie-jar "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --data "j_username=$AGILEFANT_USER&j_password=$AGILEFANT_PASSWD" --location "${AGILEFANT_HOST}:${AGILEFANT_PORT}${AGILEFANT_PATH}/j_spring_security_check" 2>&1)
}

agilefant-automation-logout() {
    if [ ! -d "$COOKIE_FILE_DIR" ]; then
         echo "COOKIE_FILE_DIR does not exist. Cannot logout."
         return 1     
	fi	
	local CURL_OUTPUT
     CURL_OUTPUT=$(curl -ivLs --cookie "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --cookie-jar "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --data "j_username=$AGILEFANT_USER&j_password=$AGILEFANT_PASSWD" --location "${AGILEFANT_HOST}:${AGILEFANT_PORT}${AGILEFANT_PATH}/j_spring_security_logout?exit=Logout" 2>&1)
	rm -r $COOKIE_FILE_DIR
}

export -f agilefant-automation-login
export -f agilefant-automation-logout
