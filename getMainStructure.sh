#!/bin/bash

SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/tools/agilefant-automation-tools.sh
source $DIR/conf/agilefant-automation-tools.conf

log 101
log 10

agilefant-automation-login
MENU_DATA=""
agilefant-automation-getMenuData MENU_DATA
MAIN=$(echo $MENU_DATA | jq -r '[.[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {class: .addClass, id: .id, title: .title})]})]}]')
PRODUCT_COUNT="$(echo $MAIN | jq '. | length')"
log "PRODUCT_COUNT is: $PRODUCT_COUNT" 1
for i in $(seq 1 "$PRODUCT_COUNT"); 
do
	PRODUCT="$(echo $MAIN | jq -r --arg I $i '.[$I | tonumber -1]')"
	PRODUCT_ID=$(echo $PRODUCT | jq '. | .id')
	log "Working on product with id: $PRODUCT_ID" 1
	PRODUCT_CHILD_COUNT="$(echo $PRODUCT | jq '. | .childs | length')"
	log "PRODUCT_CHILD_COUNT is $PRODUCT_CHILD_COUNT" 1
	for j in $(seq 1 "$PRODUCT_CHILD_COUNT");
	do
		PROJECT_OR_ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .type')
		BACKLOG_ID=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .id')
		if [ "$PROJECT_OR_ITERATION" == "PROJECT" ]; then
			log "Working on project with id: $BACKLOG_ID" 1
			PROJECT_ITERATION_COUNT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .childs | length')
			log "Number of project iterations:  $PROJECT_ITERATION_COUNT" 1
			PROJECT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
			for k in $(seq 1 "$PROJECT_ITERATION_COUNT"); 
			do
				ITERATION=$(echo $PRODUCT | jq -r --arg J $j --arg K $k '. | .childs[$J | tonumber -1] | .childs[$K | tonumber -1]') 
			done
			PROJECT_STORY_TREE=""
			agilefant-automation-getProjectStoryTree PROJECT_STORY_TREE $BACKLOG_ID	
			PROJECT_STORIES=$(echo $PROJECT_STORY_TREE | grep -o -E "storyid\S+" | grep -o "[0-9]*")
			while read -ra STORIES; do
      			for l in "${STORIES[@]}"; do
          			log "Working on story with id: $l" 1
					STORY_TASKS=""
					agilefant-automation-getStory STORY_TASKS $BACKLOG_ID $l
				TASK_IDS=$(echo $STORY_TASKS | jq -r '. | .tasks[] | .id')
				while read -ra TASKS; do
					for m in "${TASKS[@]}"; do
						log "Working on task with id: $m" 1
					done
				done <<< "$TASK_IDS"	
      			done
 			done <<< "$PROJECT_STORIES"
		fi
		if [ "$PROJECT_OR_ITERATION" == "ITERATION" ]; then
			ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
			log "Working on iteration with id: $BACKLOG_ID" 1
		fi
	done
done
agilefant-automation-logout

log 11
log 101
exit 0
