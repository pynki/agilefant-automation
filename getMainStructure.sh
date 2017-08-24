#!/bin/bash

MAIN=$(curl -s --cookie cookie.txt --cookie-jar cookie.txt --data 'j_username=admin&j_password=secret' --location http://10.254.0.33:8080/ajax/menuData.action | jq -r '[.[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {class: .addClass, id: .id, title: .title})]})]}]')

#echo $MAIN

PRODUCT_COUNT="$(echo $MAIN | jq '. | length')"
echo "PRODUCT_COUNT is: $PRODUCT_COUNT"
for i in $(seq 1 "$PRODUCT_COUNT"); 
do
	PRODUCT="$(echo $MAIN | jq -r --arg I $i '.[$I | tonumber -1]')"
	PRODUCT_ID=$(echo $PRODUCT | jq '. | .id')
	echo "Working on product with id: $PRODUCT_ID"
	PRODUCT_CHILD_COUNT="$(echo $PRODUCT | jq '. | .childs | length')"
	echo "PRODUCT_CHILD_COUNT is $PRODUCT_CHILD_COUNT"
	for j in $(seq 1 "$PRODUCT_CHILD_COUNT");
	do
		PROJECT_OR_ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .type')
		BACKLOG_ID=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .id')
		if [ "$PROJECT_OR_ITERATION" == "PROJECT" ]; then
			echo "Working on project with id: $BACKLOG_ID"
			PROJECT_ITERATION_COUNT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .childs | length')
			echo "Number of project iterations:  $PROJECT_ITERATION_COUNT"
			PROJECT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
			for k in $(seq 1 "$PROJECT_ITERATION_COUNT"); 
			do
				ITERATION=$(echo $PRODUCT | jq -r --arg J $j --arg K $k '. | .childs[$J | tonumber -1] | .childs[$K | tonumber -1]') 
			done	
			PROJECT_STORIES=$(curl -s --cookie cookie.txt --cookie-jar cookie.txt --data "projectId=$BACKLOG_ID" --location http://10.254.0.33:8080/ajax/getProjectStoryTree.action | grep -o -E "storyid\S+" | grep -o "[0-9]*")
		
			while read -ra STORIES; do
      			for l in "${STORIES[@]}"; do
          			echo "Working on story with id: $l"
					STORY_TASKS=$(curl -s --cookie cookie.txt --cookie-jar cookie.txt --data "projectId=$BACKLOG_ID" --location http://10.254.0.33:8080/ajax/retrieveStory.action?storyId=$l)
				TASK_IDS=$(echo $STORY_TASKS | jq -r '. | .tasks[] | .id')
				while read -ra TASKS; do
					for m in "${TASKS[@]}"; do
						echo "Working on task with id: $m"
					done
				done <<< "$TASK_IDS"	
      			done
 			done <<< "$PROJECT_STORIES"
		fi
		if [ "$PROJECT_OR_ITERATION" == "ITERATION" ]; then
			ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
			echo "Working on iteration with id: $BACKLOG_ID"
		fi
	done
done
