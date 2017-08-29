#!/bin/bash

SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/tools/agilefant-automation-tools.sh
source $DIR/conf/agilefant-automation-tools.conf

log 101
log 10

MAIN_JSON='{"products": [], "users": []}'


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
###
	if [ ! "$PRODUCT_ID" == "-1" ]; then
		agilefant-automation-getProduct-simple X_PRODUCT $PRODUCT_ID
	else
		X_PRODUCT='{"id": -1, "type": 0, "iterations":[]}'
	fi
###
	PRODUCT_CHILD_COUNT="$(echo $PRODUCT | jq '. | .childs | length')"
	log "PRODUCT_CHILD_COUNT is $PRODUCT_CHILD_COUNT" 1
	for j in $(seq 1 "$PRODUCT_CHILD_COUNT");
	do
		PROJECT_OR_ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .type')
		BACKLOG_ID=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .id')
		if [ "$PROJECT_OR_ITERATION" == "PROJECT" ]; then
			log "Working on project with id: $BACKLOG_ID" 1
###
			agilefant-automation-getProject-simple X_PROJECT $BACKLOG_ID
###
			PROJECT_ITERATION_COUNT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .childs | length')
			log "Number of project iterations:  $PROJECT_ITERATION_COUNT" 1
			PROJECT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
			for k in $(seq 1 "$PROJECT_ITERATION_COUNT"); 
			do
				ITERATION=$(echo $PRODUCT | jq -r --arg J $j --arg K $k '. | .childs[$J | tonumber -1] | .childs[$K | tonumber -1]') 
				ITERATION_ID=$(echo $ITERATION | jq '. | .id')
				agilefant-automation-getIteration ITERATION_JSON  $ITERATION_ID
###
				agilefant-automation-getIteration-simple X_ITERATION $ITERATION_ID
###
				ITERATION_TASKS_COUNT=$(echo $ITERATION_JSON | jq '. | .tasks | length')
				for x in $(seq 1 "$ITERATION_TASKS_COUNT");
				do
					TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
					log "Working on task with ID: $TASK_ID" 1
###
					agilefant-automation-getTask-simple X_TASK $TASK_ID

				X_ITERATION=$(echo $X_ITERATION | jq --arg Z $x --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')	
###
				done
####
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
###
                                        agilefant-automation-getTask-simple X_TASK $TASK_ID
                                        X_STORY=$(echo $X_STORY | jq --arg Z $z --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
###i

                                        done

X_ITERATION=$(echo $X_ITERATION | jq --arg L "$f" --arg X "$X_STORY" '. | .stories[$L | tonumber -1] |= .+ ($X | fromjson)')
done



###
				X_PROJECT=$(echo $X_PROJECT | jq --arg K $k --arg X "$X_ITERATION" '. | .iterations[$K | tonumber -1] |= .+ ($X | fromjson)')
###
			done
			agilefant-automation-getProjectStoryTree PROJECT_STORY_TREE $BACKLOG_ID	
			PROJECT_STORIES=$(echo $PROJECT_STORY_TREE | grep -o -E "storyid\S+" | grep -o "[0-9]*")
###
echo "DDDDD: $PROJECT_STORIES"
count=1
###
			while read -ra STORIES; do
      			for l in "${STORIES[@]}"; do
          			log "Working on story with id: $l" 1
###
					agilefant-automation-getStory-simple X_STORY $l
echo "count: $count"
###					
					agilefant-automation-getStory STORY_TASKS $l

				STORY_TASKS_COUNT=$(echo $STORY_TASKS | jq -r '. | .tasks | length')
					for z in $(seq 1 "$STORY_TASKS_COUNT");
					do
						TASK_ID=$(echo $STORY_TASKS | jq --arg Z $z '. | .tasks[$Z | tonumber -1] | .id')
					log "Working on task: $TASK_ID" 1
###
					agilefant-automation-getTask-simple X_TASK $TASK_ID
					X_STORY=$(echo $X_STORY | jq --arg Z $z --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
###i

					done
      			done
###
echo "@@@@@@@@@@@@@@@@@@@: $l"
				X_PROJECT=$(echo $X_PROJECT | jq --arg L "$count" --arg X "$X_STORY" '. | .stories[$L | tonumber -1] |= .+ ($X | fromjson)')
                    count=$(($count+1))
###	
 			done <<< "$PROJECT_STORIES"

###
	#echo "||||||||||||||||||||||||||||||||||||||||||||||||||||"
	#echo "X_PROJECT= $X_PROJECT"

    X_PRODUCT=$(echo $X_PRODUCT | jq --arg J $j --arg X "$X_PROJECT" '. | .projects[$J | tonumber -1] |= .+ ($X | fromjson)')
#	echo "X_PRODUCT= $X_PRODUCT"

	 #   echo "||||||||||||||||||||||||||||||||||||||||||||||||||||"
###

		fi
		if [ "$PROJECT_OR_ITERATION" == "ITERATION" ]; then
			ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
			log "Working on iteration with id: $BACKLOG_ID" 1
###
			agilefant-automation-getIteration-simple X_ITERATION $BACKLOG_ID
###

			ITERATION_ID=$(echo $ITERATION | jq '. | .id')
			agilefant-automation-getIteration ITERATION_JSON  $ITERATION_ID
            ITERATION_TASKS_COUNT=$(echo $ITERATION_JSON | jq '. | .tasks | length')

####
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
###
                                        agilefant-automation-getTask-simple X_TASK $TASK_ID
                                        X_STORY=$(echo $X_STORY | jq --arg Z $z --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
###i

                                        done

X_ITERATION=$(echo $X_ITERATION | jq --arg L "$f" --arg X "$X_STORY" '. | .stories[$L | tonumber -1] |= .+ ($X | fromjson)')
done

####
            for x in $(seq 1 "$ITERATION_TASKS_COUNT");
            do
                TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
                log "Working on task with ID: $TASK_ID" 1

###
                    agilefant-automation-getTask-simple X_TASK $z
                    X_ITERATION=$(echo $X_ITERATION | jq --arg Z $x --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
###
            done
###
			X_PRODUCT=$(echo $X_PRODUCT | jq --arg J $j --arg X "$X_ITERATION" '. | .iterations[$J | tonumber -1] |= .+ ($X | fromjson)')	
###
		fi
	done

echo "#####################################################################"

echo "i = $i"

MAIN_JSON=$(echo $MAIN_JSON | jq --arg I "$i" --arg X "$X_PRODUCT" '. | .products[ $I | tonumber -1] |= .+ ($X | fromjson)')
done

echo "#####################################################################"
agilefant-automation-getUsers USERS

USERS_COUNT=$(echo $USERS | jq '. | length')
for i in $(seq 1 "$USERS_COUNT");
do
    USER=$(echo $USERS | jq --arg I $i '.[($I | tonumber -1)] | del(.class)')
    MAIN_JSON=$(echo $MAIN_JSON | jq --arg I $i --arg U "$USER" '. | .users[($I | tonumber -1)] |= .+ ($U | fromjson)')
done

###################END#########################################################
echo "MAIN_JSON: $MAIN_JSON"

agilefant-automation-logout

log 11
log 101
exit 0
