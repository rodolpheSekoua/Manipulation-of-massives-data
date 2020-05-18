#!/bin/bash

SHELL_PROFILE="$HOME/.bashrc"

#set the install location, $home is set by default
SPARK_INSTALL_LOCATION=$HOME

#specify the url to download spark from
SPARK_URL=https://downloads.apache.org/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz


SPARK_FOLDER_NAME=spark-2.4.5-bin-hadoop2.7.tgz

SPARK_MD5=3b8dd273912a0aa8df79b49b5fdf2624
echo "This is an automated script for installing spark"

# create a path to config spark
# This directory will be created if it does not exist otherwise nothing to do
mkdir -p $HOME/scripts

if [[ -d $HOME/scripts ]]; then
    read -r -p "Would you like to create the jupyspark.sh script for launching a local jupyter spark server? [y/N] " response
    if [[ $response -eq "y" ]]; then
        echo "#!/bin/bash
        export PYSPARK_DRIVER_PYTHON=jupyter
        export PYSPARK_DRIVER_PYTHON_OPTS=\"notebook --NotebookApp.open_browser=True --NotebookApp.ip='localhost' --NotebookApp.port=8888\"
        \${SPARK_HOME}/bin/pyspark \
        --master local[4] \
        --executor-memory 1G \
        --driver-memory 1G \
        --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" \
        --packages com.databricks:spark-csv_2.11:1.5.0 \
        --packages com.amazonaws:aws-java-sdk-pom:1.10.34 \
        --packages org.apache.hadoop:hadoop-aws:2.7.3" >> $HOME/scripts/jupyspark.sh
        # transform the file in executable file
        chmod +x $HOME/scripts/jupyspark.sh
    else
        echo "\nNothing to do..."    
    fi

    read -r -p "Would you like to create the localsparksubmit.sh script for submittiing local python scripts through spark-submit? [y/N] " response
    if [[ $response -eq "y" ]]; then
        echo "#!/bin/bash
        \${SPARK_HOME}/bin/spark-submit \
        --master local[4] \
        --executor-memory 1G \
        --driver-memory 1G \
        --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" \
        --packages com.databricks:spark-csv_2.11:1.5.0 \
        --packages com.amazonaws:aws-java-sdk-pom:1.10.34 \
        --packages org.apache.hadoop:hadoop-aws:2.7.3 \
        \$1" > $HOME/scripts/localsparksubmit.sh

        chmod +x $HOME/scripts/localsparksubmit.sh
    fi
fi

#check to see if JDK is installed
javac -version 2> /dev/null
if [! $? -eq 0]; then
    #install JDK
    if [[ $(uname -s) = 'Linux']]
        echo "Downloading JDK..."
        sudo add-apt-repository ppa:webupd8team/java
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
        sudo apt-get update
        sudo apt-get install oracle-java8-installer
    fi
fi

SUCCESSFUL_SPARK_INSTALL=0
SPARK_INSTALL_TRY=0

if [[ $(uname -s)= "Linux"]]; then 
    echo -e "\n\tDetected Linux as the Operating System\n"
    # the while condition is true when the successfull equals to 0
    while [$SUCCESSFUL_SPARK_INSTALL -eq 0]
    do
        curl $SPARK_URL > $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME
        #check MD5 hash
        if [[$(openssl md5 $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME |sed -e "s/^.*//") == "$SPARK_MD5" ]]
        then 
            tar -xzf $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME -C $SPARK_INSTALL_LOCATION
            rm $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME
            pip install py4j
            SUCCESSFUL_SPARK_INSTALL=1
        else
            echo "ERROR: Spark MD5 hash does not match"
            echo "$(openssl md5 $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME | sed -e "s/^.*//") != $SPARK_MD5"
            if [$ SPARK_INSTALL_TRY -lt 3]
            then
                echo -e "\nTrying Spark install again\n"
                SPARK_INSTALL_TRY=$[$SPARK_INSTALL_TRY+1]
                echo $SPARK_INSTALL_TRY
                SPARK_MD5=7776f28d5e0a2ad04b5046c1786ee9cd
            else
                echo -e "\nSPARK INSTALL FAILED\n"
                echo -e "Check the MD5 hash and run again"
                exit 1
    done
else
    echo "Unable to detect Operating System"
    exit 1
fi

echo "
# Spark variables
export SPARK_HOME=\"$SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME\"
export PYTHONPATH=\"$SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME/python/:$PYTHONPATH\"
# Spark 2
export PYSPARK_DRIVER_PYTHON=ipython
export PATH=\$SPARK_HOME/bin:\$PATH
alias pyspark=\"$SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME/bin/pyspark \
    --conf spark.sql.warehouse.dir='file:///tmp/spark-warehouse' \
    --packages com.databricks:spark-csv_2.11:1.5.0 \
    --packages com.amazonaws:aws-java-sdk-pom:1.10.34 \
    --packages org.apache.hadoop:hadoop-aws:2.7.3\"" >> $SHELL_PROFILE

source $SHELL_PROFILE

echo "INSTALL COMPLETE"
