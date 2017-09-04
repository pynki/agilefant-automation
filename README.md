# Project to automate the opensource agilefant

All scripts are intended to be used with the run.sh wrapper script. they depend on the logging and tool functions! See the conf/ folder for the run.sh config files.

there are things that are totally left out right now: labels, ranking, spending effort, stroy tree management and user management. if i have the time or the need to implement them i will do it.

## scripts:

### agilefant_installation.sh

script to automatically install agilefant opensource on a ubuntu (or apt based system). tested with a ubuntu 16.04 x86_64 minimal installation

### agilefant_deleteAll.sh

deletes the whole agilefant structure or parts of it. see the conf/agilefant-deleteAll.conf file for options. 

### agilefant_buildTestStructure.sh

script to build a agilefant object structure (for testing purposes...at least thats how i use it). this script may take some time to execute! depending on the configuration it can create a massive amount of objects!
Creates PRODUCT_COUNT products
Creates STANDALONE_ITERATION_COUNT standalone iterations
Creates PRODUCT_COUNT*PROJECT_PER_PRODUCT projects
Creates PRODUCT_COUNT*PROJECT_PER_PRODUCT*ITERATION_PER_PROJECT project iterations
Creates PRODUCT_COUNT*PROJECT_PER_PRODUCT*ITERATION_PER_PROJECT*STORIES_PER_ITERATION + PRODUCT_COUNT*PROJECT_PER_PRODUCT*STORIES_PER_PROJECT + STANDALONE_ITERATION_COUNT*STORIES_PER_ITERATION stories
Creates (PRODUCT_COUNT*PROJECT_PER_PRODUCT*ITERATION_PER_PROJECT*STORIES_PER_ITERATION + PRODUCT_COUNT*PROJECT_PER_PRODUCT*STORIES_PER_PROJECT + STANDALONE_ITERATION_COUNT*STORIES_PER_ITERATION)*TASKS_PER_STORY + (PRODUCT_COUNT*PROJECT_PER_PRODUCT*ITERATION_PER_PROJECT + STANDALONE_ITERATION_COUNT)*TASKS_PER_ITERATION tasks

set all the values to 10 and you will end up with 22100 tasks...

### tools/agilefant-automation-tools.sh

script to provide a agilefant commandline api. calls for creating, deleting, editing objects are implemented. provides a function to get a json representation of all the objects to perform searches etc. login/logout function. function to execute callbacks for each object, see the agilefant_deleteAll.sh for an example on how to use it.

# WARNING:

using the ./tools/agilefant-automation-tools.sh functions might come with uncalculated risks! the delete functions will be happy to delete products etc. without asking you any questions! there may be corner cases that are not covered or tested in all the functions!

### all this is work in progress and should not be used if you do not unsderstand the scripts! 