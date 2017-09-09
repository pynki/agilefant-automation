# IMPORTANT

These scripts are intended to be called from the run.sh wrapper script. Please see [runsh github repository](https://github.com/pynki/runsh) on how to use the wrapper script. 

Before cloning this repository clone the runsh wrapper script repository.

`git clone https://github.com/pynki/runsh`

then chaneg the folder to the cloned repo:

`cd ./runsh`

and run the scripts by passing the config file to the runsh wrapper script

`./run.sh /path/to/what/ever/script.conf`

# About

there are things that are totally left out right now: labels, ranking, spending effort, stroy tree management and user management. if i have the time or the need to implement them i will do it.

These scripts are just examples on how to use the [agilefant-API](https://github.com/pynki/agilefant-API) functions. 

## Scripts

### agilefant_installation.sh

Script to automatically install agilefant opensource on a ubuntu (or apt based system). Tested with a ubuntu 16.04 x86_64 minimal installation. It fixes the java version problem that occurs with the [original agilefant installation guide](https://github.com/Agilefant/agilefant/wiki/Agilefant-installation-guide). The java7 package is no longer available from the referenced ppa. This script installs oracle java8!

Please see the config file for runsh at:

`conf/agilefant_installation.conf` 

for options.

### agilefant_deleteAll.sh

Deletes the whole agilefant structure or parts of it.

Please see the config file for runsh at:

`conf/agilefant_deleteAll.conf` 

for options.

### agilefant_buildTestStructure.sh

Script to build a agilefant object structure (for testing purposes...at least thats how i use it). This script may take some time to execute! Depending on the configuration it can create a massive amount of objects!

Please see the config file for runsh at:

`conf/agilefant_buildTestStructure.conf` 

for options.

### agilefant_assignUser.sh

Script to assign spcific stories/tasks to users based on their state.

Please see the config file for runsh at:

`conf/agilefant_assignUser.conf` 

for options.

### agilefant_createIterations.sh

Script to create iterations. Either for every project or for standalone iterations.

Please see the config file for runsh at:

`conf/agilefant_createIterations.conf` 

for options.

# Remarks

This is work in progress. There might be bugs, unhandled corner cases or plain stupid code in the scripts. It works for me, in the cases i use it. If you need something changed: open an issue or fork the code. I am happy about pull requests.

