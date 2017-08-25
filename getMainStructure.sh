#!/bin/bash

SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/tools/agilefant-automation-tools.sh
source $DIR/conf/agilefant-automation-tools.conf

log 101
log 10

agilefant-automation-login
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
				ITERATION_ID=$(echo $ITERATION | jq '. | .id')
				agilefant-automation-getIteration ITERATION_JSON  $ITERATION_ID
				ITERATION_TASKS_COUNT=$(echo $ITERATION_JSON | jq '. | .tasks | length')
#				echo "IT TASKS COUNT: $ITERATION_TASKS_COUNT"
				
				for x in $(seq 1 "$ITERATION_TASKS_COUNT");
				do
					TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
					log "Working on task with ID: $TASK_ID" 1
				done
			done
			agilefant-automation-getProjectStoryTree PROJECT_STORY_TREE $BACKLOG_ID	
			PROJECT_STORIES=$(echo $PROJECT_STORY_TREE | grep -o -E "storyid\S+" | grep -o "[0-9]*")
			while read -ra STORIES; do
      			for l in "${STORIES[@]}"; do
          			log "Working on story with id: $l" 1
					agilefant-automation-getStory STORY_TASKS $l

#echo "ccccccccccccccccc $STORY_TASKS"

				STORY_TASKS_COUNT=$(echo $STORY_TASKS | jq -r '. | .tasks | length')
#echo "VVVVVVVV: $STORY_TASKSS"
#echo "ZZZZZZZZZZZZ: $TASK_IDS"
				for z in $(seq 1 "$STORY_TASKS_COUNT");
				do
					TASK_ID=$(echo $STORY_TASKS | jq --arg Z $z '. | .tasks[$Z | tonumber -1] | .id')
				log "Working on task: $TASK_ID" 1
				done
#				while read -ra TASKS; do
#					for m in "${TASKS[@]}"; do
#						log "Working on task with id: $m" 1
#					done
#				done <<< "$TASK_IDS"	
      			done
 			done <<< "$PROJECT_STORIES"
		fi
		if [ "$PROJECT_OR_ITERATION" == "ITERATION" ]; then
			ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
			log "Working on iteration with id: $BACKLOG_ID" 1
			ITERATION_ID=$(echo $ITERATION | jq '. | .id')
			agilefant-automation-getIteration ITERATION_JSON  $ITERATION_ID
            ITERATION_TASKS_COUNT=$(echo $ITERATION_JSON | jq '. | .tasks | length')
 #           echo "IT TASKS COUNT: $ITERATION_TASKS_COUNT"
            for x in $(seq 1 "$ITERATION_TASKS_COUNT");
            do
                TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
                log "Working on task with ID: $TASK_ID" 1
            done
            
		fi
	done
done
agilefant-automation-logout

log 11
log 101
exit 0

# json should look like this:
# {products: [{product1}, {product2}, ...], user: [{user1}, {user2}, ...]}
# a product looks like this: {id:1,data: {}, standalone: true/false, projects: [{id:1,data:{}, iterations: [{id:1,data:{}, tasks:[{id:1,data:{}}]}], stories: [{id:1,data:{}, tasks:[{id:1,data:{}}]}]}]}
#a user looks like this: {id:1,data:{}}



