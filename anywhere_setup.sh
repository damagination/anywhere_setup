#!/bin/sh

#Author: Damas Mlabwa
#Date: August 14, 2014

#This script will download necessary files and help setup basic configuration required to install
#Maximo Anywhere 7.5.1 on a computer that has NOTHING on it.
#Modify the script to handle computers with previous installs, and other scenarios like different install
#locations.

#DISCLAIMER
#The script has only been used once, use it at your own risk.

blue='\e[0;34m'
NC='\e[0m'

# Set JAVA_HOME
function setJAVA {

	echo -e "${blue}Setting up JAVA_HOME ...${NC}"
	echo

	export JAVA_HOME=/usr/java/jdk1.70.0_60
	export PATH=$JAVA_HOME/bin:$PATH
}

# RPM packages only, 64-bit
function getJAVA {

	cd ~/Downloads

	echo -e "${blue}Downloading ORACLE JDK 7 ...${NC}"

	#ORACLE_JDK_7_URL = "http://download.oracle.com/otn-pub/java/jdk/7u60-b19/jdk-7u60-linux-x64.rpm"

	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u60-b19/jdk-7u60-linux-x64.rpm"

	sudo rpm -ivh jdk-7u60-linux-x64.rpm

	setJAVA
}

function checkJAVA {
	if command -v javac >/dev/null 2>&1; then
		echo -e "${blue} JDK found ...${NC}"
		setJAVA
	else
		echo -e "${blue}We will try to set JAVA and JAVA_HOME for you${NC}"
		getJAVA
	fi
}

function verifyJAVA {
	if command -v javac >/dev/null; then
		echo -e "${blue}Oracle JDK installed successfully${NC}"
	else
		echo  -e "${blue}Couldn't install ORACLE JDK, please install manually${NC}"
	fi
}

function installAndroidPlatforms {

	cd ~/android-sdk-linux/tools

	chmod -R 755 ./

	echo -e "${blue}Select plaforms and tools to install, see manual for supported platforms${NC}"
	./android
}



#Installation Paths
ANDROID_SDK_ROOT=~/android-sdk-linux
TMP=/tmp/android-sdk-linux
mkdir $TMP

# Get the Android SDK
if [ ! -d $ANDROID_SDK_ROOT ]; then
	DROID_SDK_URL=`
        curl -s https://developer.android.com/sdk/index.html#ExistingIDE | 
        grep 'id="linux-tools"' |
        sed 's/.*href="\([^"]*\)".*$/\1/'`
# courtesy of http://sed.sourceforge.net/grabbag/scripts/list_urls.sed

	cd $TMP
	wget $DROID_SDK_URL --output-document=android-sdk.tgz
	echo  -e "${blue}Download Complete ...${NC}"
	echo
	echo -e "${blue}Extracting files ...${NC}"
	tar -xvzf android-sdk.tgz
	mv android-sdk-linux $HOME
	cd $HOME

	echo
	echo -e "${blue}Android SDK Location ~/android-sdk-linux${NC}"
	echo

	installAndroidPlatforms
fi

# Check for JAVA, if not found get Oracle JAVA Dev. Kit 
if [ -z $JAVA_HOME]; then
	echo -e "${blue}JAVA_HOME is not set${NC}"
	checkJAVA
fi


# Get Anywhere zip file
ANYHWERE_751_ROOT=/opt/IBM/AnywhereWorkManager
TMP1=/tmp/AnywhereWorkManager
mkdir $TMP1

if [ ! -d $ANYHWERE_751_ROOT ]; then
	echo -e "${blue}Downloading maximo anywhere 7.5.1 ...${NC}"
	ANYWHERE_URL= #fill in URL here, removed IBM internal URL

	cd $TMP1
	wget $ANYWHERE_URL
	unzip Max_Anywhere_WM_V751.zip -d ./AnywhereWorkManager

	#Start Installer
	echo -e "${blue}Continue with the launchpad installer ...${NC}"
	cd AnywhereWorkManager
	chmod -R 755 ./
	sudo ./launchpad.sh
fi


#Clean up
rm -rf $TMP1
rm -rf $TMP
cd Downloads
rm jdk*
