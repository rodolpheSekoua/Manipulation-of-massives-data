#!/bin/bash

java -version 2> /dev/null

if [[ $(uname -s) -eq "Linux" ]]; then
        echo "Downloading JDK..."
        sudo add-apt-repository ppa:webupd8team/java
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
        sudo apt-get update
        sudo apt-get install oracle-java8-installer
else
        echo "Unknown operating system"
fi
