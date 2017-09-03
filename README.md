# Project to automate the opensource agilefant

All scripts are intended to be used with the run.sh wrapper script. they depend on the logging and tool functions! See the conf/ folder for the run.sh config files.

there are things that are totally left out right now: labels, ranking, spending effort, stroy tree management and user management. if i have the time or the need to implement them i will do it.

## scripts:

### agilefant_installation.sh

script to automatically install agilefant opensource on a ubuntu (or apt based system). tested with a ubuntu 16.04 x86_64 minimal installation

### agilefant_installation.sh

deletes the whole agilefant structure or parts of it. see the conf/agilefant-deleteAll.conf file for options. 

### tools/agilefant-automation-tools.sh

script to provide a agilefant commandline api. calls for creating, deleting, editing objects are implemented. provides a function to get a json representation of all the objects to perform searches etc. login/logout function. function to execute callbacks for each object, see the agilefant_deleteAll.sh for an example on how to use it.

# WARNING:

using the ./tools/agilefant-automation-tools.sh functions might come with uncalculated risks! the delete functions will be happy to delete products etc. without asking you any questions! there may be corner cases that are not covered or tested in all the functions!

### all this is work in progress and should not be used if you do not unsderstand the scripts! 