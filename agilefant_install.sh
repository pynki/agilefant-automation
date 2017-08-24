#!/bin/bash

SCRIPT_LOG_PREFIX=[`basename "$0"`]
log 101
log 10

### set preselections for GUIless mysql install
netExe 0 "echo 'mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWD' |  debconf-set-selections" $TARGET_IP $TARGET_USER $TARGET_PASSWD

netExe 0 "echo 'mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWD' | debconf-set-selections" $TARGET_IP $TARGET_USER $TARGET_PASSWD



### install tomcat and mysql
netExe 0 "apt-get update 2>&1" $TARGET_IP $TARGET_USER $TARGET_PASSWD
netExe 0 "apt-get upgrade -y 2>&1" $TARGET_IP $TARGET_USER $TARGET_PASSWD 
netExe 0 "apt-get install $INSTALLS -y 2>&1" $TARGET_IP $TARGET_USER $TARGET_PASSWD

### install oracle java
if [ $USE_ORACLE -eq 1 ]; then
	echo "install oracle java"
	# see:https://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option
	netExe 0 "echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections" $TARGET_IP $TARGET_USER $TARGET_PASSWD
	netExe 0 "echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true' | debconf-set-selections" $TARGET_IP $TARGET_USER $TARGET_PASSWD	
	netExe 0 "apt-get install $INSTALLS_JAVA_PRE -y 2>&1" $TARGET_IP $TARGET_USER $TARGET_PASSWD
	netExe 0 "apt-add-repository ppa:webupd8team/java" $TARGET_IP $TARGET_USER $TARGET_PASSWD	
	netExe 0 "apt-get update" $TARGET_IP $TARGET_USER $TARGET_PASSWD
	netExe 0 "apt-get install $INSTALLS_JAVA_POST -y 2>&1" $TARGET_IP $TARGET_USER $TARGET_PASSWD
	netExe 0 "update-java-alternatives -s /usr/lib/jvm/java-8-oracle" $TARGET_IP $TARGET_USER $TARGET_PASSWD
	netExe 0 "sed -i '/JAVA_HOME=/c\JAVA_HOME=/usr/lib/jvm/java-8-oracle' /etc/default/tomcat7" $TARGET_IP $TARGET_USER $TARGET_PASSWD
fi

### install fonts
if [ $INSTALL_FONTS -eq 1 ]; then
	echo "install fonts"
	#https://askubuntu.com/questions/16225/how-can-i-accept-the-microsoft-eula-agreement-for-ttf-mscorefonts-installer	
	netExe 0 "echo 'ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true' |  debconf-set-selections" $TARGET_IP $TARGET_USER $TARGET_PASSWD
	netExe 0 "apt-get install $INSTALLS_FONTS -y 2>&1" $TARGET_IP $TARGET_USER $TARGET_PASSWD
fi

### database setup
SQL_STMT="\"create database agilefant; grant all on agilefant.* to agilefant@localhost identified by '$AGILEFANT_DB_PASSWD';"\"
netExe 0 "mysql -u 'root' -p$MYSQL_ROOT_PASSWD -e $SQL_STMT" $TARGET_IP $TARGET_USER $TARGET_PASSWD

### create working folders
netExe 0 "mkdir $WORK_DIR_BASE" $TARGET_IP $TARGET_USER $TARGET_PASSWD
netExe 0 "mkdir $WARZIP_DIR" $TARGET_IP $TARGET_USER $TARGET_PASSWD

### download/upload agilefant zip file
if [ $COPY_ZIP -eq 0 ]; then
	netExe 0 "wget https://downloads.sourceforge.net/project/agilefant/Agilefant3/agilefant-3.5.4.zip" $TARGET_IP $TARGET_USER $TARGET_PASSWD 
	netExe 0 "mv $ZIP_NAME $WORK_DIR_BASE/" $TARGET_IP $TARGET_USER $TARGET_PASSWD
else
	netCopy "$COPY_ZIP_LOCATION/$ZIP_NAME" "$WORK_DIR_BASE/$ZIP_NAME" $TARGET_IP $TARGET_USER $TARGET_PASSWD
fi

### unzip agilefant.war
netExe 0 "unzip -q -d $WORK_DIR_BASE $WORK_DIR_BASE/$ZIP_NAME" $TARGET_IP $TARGET_USER $TARGET_PASSWD
netExe 0 "cp $WORK_DIR_BASE/agilefant.war $WARZIP_DIR/agilefant.war" $TARGET_IP $TARGET_USER $TARGET_PASSWD
netExe 0 "unzip -q -d $WARZIP_DIR/ $WARZIP_DIR/agilefant.war" $TARGET_IP $TARGET_USER $TARGET_PASSWD

### change the agilefant db password and zip the changed files
netExe 0 "sed -i '/password/ s/agilefant/$AGILEFANT_DB_PASSWD/' $WARZIP_DIR/WEB-INF/agilefant.conf" $TARGET_IP $TARGET_USER $TARGET_PASSWD 
netExe 0 "cd $WARZIP_DIR && zip -q -r agilefant.war META-INF/ WEB-INF/ static/ *.*" $TARGET_IP $TARGET_USER $TARGET_PASSWD

### stop tomcat 
netExe 0 "service tomcat7 stop 2>&1" $TARGET_IP $TARGET_USER $TARGET_PASSWD

### move agilefant.war to tomcat webapps folder
netExe 0 "mv $WARZIP_DIR/agilefant.war /var/lib/tomcat7/webapps" $TARGET_IP $TARGET_USER $TARGET_PASSWD

### rename agilefant.war to ROOT.war
if [ ! $RENAME_WAR -eq 0 ]; then
	netExe 0 "rm -r /var/lib/tomcat7/webapps/ROOT" $TARGET_IP $TARGET_USER $TARGET_PASSWD
	netExe 0 "mv /var/lib/tomcat7/webapps/agilefant.war /var/lib/tomcat7/webapps/ROOT.war" $TARGET_IP $TARGET_USER $TARGET_PASSWD
fi

### ubuntu modifications for tomcat
if [ $MOD_FOR_UBUNTU -eq 1 ]; then
	echo "modify for ubuntu"
	# -XX:+UseConcMarkSweepGC should be there by default in aubuntu install
	# TODO some of these options seem to be not valid anymore with java 8
	netExe 0 "sed -i '/^JAVA_OPTS/c\JAVA_OPTS=\"-Djava.awt.headless=true -Xms256m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode\"' /etc/default/tomcat7" $TARGET_IP $TARGET_USER $TARGET_PASSWD
fi

### start tomcat
netExe 0 "service tomcat7 start 2>&1" $TARGET_IP $TARGET_USER $TARGET_PASSWD

### clean up
netExe 0 "rm -r $WORK_DIR_BASE" $TARGET_IP $TARGET_USER $TARGET_PASSWD

log 11
log 101

exit 0
