#!/bin/bash


callbackProduct() {	
	log "callbackProduct() $1" 0
	if [ $1 == "-1" ]; then
		return 0
	fi
	local project_nr
	for project_nr in $(seq 1 "$PROJECT_PER_PRODUCT");
	do
		PROJECT='{"productId": '$1', "project.startDate": 1503964800000, "project.endDate": 1505210400000, "assigneesChanged": true,"project.name": "Project'$project_nr'-'$1'", "project.description": "DESCRIPTION", "assigneeIds": [3], "project.backlogSize": "5h", "project.baselineLoad": "6h", "project.status": "BLACK"}'
		agilefant-automation-createProject "$PROJECT" RETURN_VAL NEW_ID
	done
}

callbackProject() {
	log "callbackProject() $1" 0
	local iteration_nr
	for iteration_nr in $(seq 1 "$ITERATION_PER_PROJECT");
	do
		ITERATION='{"parentBacklogId": '$1', "iteration.startDate": 1503964800000, "iteration.endDate": 1505210400000, "assigneesChanged": true,"iteration.name": "Iteration'$iteration_nr'-'$1'", "iteration.description": "DESCRIPTION", "teamsChanged": true, "assigneeIds": [3], "teamIds": [2],"iteration.backlogSize": "10h", "iteration.baselineLoad": "10h"}'
		agilefant-automation-createIteration "$ITERATION" RETURN_VAL NEW_ID
	done
	local story_nr
	for story_nr in $(seq 1 "$STORIES_PER_PROJECT");
	do
		STORY='{"backlogId": '$1', "usersChanged": true, "story.name": "Story'$story_nr'-'$1'", "story.description": "DESCRIPTION", "userIds": [3], "story.storyValue": 10, "story.storyPoints": 20, "story.state": "NOT_STARTED"}'
		agilefant-automation-createStory "$STORY" RETURN_VAL NEW_ID
	done
}

callbackIteration() {
	log "callbackIteration() $1" 0
	local story_nr
	for story_nr in $(seq 1 "$STORIES_PER_ITERATION");
	do
		STORY='{"backlogId": '$1',"iteration": '$1', "usersChanged": true, "story.name": "Story'$story_nr'-'$1'", "story.description": "DESCRIPTION", "userIds": [3], "story.storyValue": 10, "story.storyPoints": 20, "story.state": "NOT_STARTED"}'
		agilefant-automation-createStory "$STORY" RETURN_VAL NEW_ID
	done
	local task_nr
	for task_nr in $(seq 1 "$TASKS_PER_ITERATION");
	do
		TASK='{"iterationId": '$1', "responsiblesChanged": true, "task.name": "task'$task_nr'-'$1'", "task.description": "DESCRIPTION", "newResponsibles": [3], "task.state": "NOT_STARTED", "task.effortLeft": 123}'
		agilefant-automation-createTask "$TASK" RETURN_VAL NEW_ID
	done
}

callbackStory() {
	log "callbackStory() $1" 0
	local task_nr
	for task_nr in $(seq 1 "$TASKS_PER_STORY");
	do
		TASK='{"storyId": '$1', "responsiblesChanged": true, "task.name": "task'$task_nr'-'$1'", "task.description": "DESCRIPTION", "newResponsibles": [3], "task.state": "NOT_STARTED", "task.effortLeft": 123}'
		agilefant-automation-createTask "$TASK" RETURN_VAL NEW_ID
	done
}

SCRIPT_LOG_PREFIX=[`basename "$0"`]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log 101
log 10

source $DIR/conf/agilefant-automation-tools.conf
source $DIR/tools/agilefant-automation-tools.sh

agilefant-automation-login

# create products
for product_nr in $(seq 1 "$PRODUCT_COUNT");
do
	PRODUCT='{"teamsChanged": true, "product.name": "Product'$product_nr'", "product.description": "Description", "teamIds": [2]}'
	agilefant-automation-createProduct "$PRODUCT" RETURN_VAL NEW_ID
done

# create standalone iterations
for iteration_nr in $(seq 1 "$STANDALONE_ITERATION_COUNT");
do
	ITERATION='{"iteration.startDate": 1503964800000, "iteration.endDate": 1505210400000, "assigneesChanged": true,"iteration.name": "Standalone Iteration'$iteration_nr'", "iteration.description": "DESCRIPTION", "teamsChanged": true, "assigneeIds": [3], "teamIds": [2],"iteration.backlogSize": "10h", "iteration.baselineLoad": "10h"}'
	agilefant-automation-createIteration "$ITERATION" RETURN_VAL NEW_ID
done

# create projects
agilefant-automation-getMainStructure LOCAL_JSON
agilefant-automation-execForAll "$LOCAL_JSON" "callbackProduct" "" "" "" ""

# create iterations
agilefant-automation-getMainStructure LOCAL_JSON
agilefant-automation-execForAll "$LOCAL_JSON" "" "callbackProject" "" "" ""

# create stories
agilefant-automation-getMainStructure LOCAL_JSON
agilefant-automation-execForAll "$LOCAL_JSON" "" "" "callbackIteration" "" ""

# create tasks
agilefant-automation-getMainStructure LOCAL_JSON
agilefant-automation-execForAll "$LOCAL_JSON" "" "" "" "callbackStory" ""

agilefant-automation-logout

log 11
log 101
exit 0