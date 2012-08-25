#!/bin/sh
#
####################################
# iTunes Command Line Interface v0.1
#
# @author jmnunezizu
####################################

APP_NAME=`basename $0i`
error_msg=""
usage=""

help() {
    echo "Usage: $APP_NAME add <directory>"
}

error() {
    echo "Error: $error_msg"
    echo "Usage: $APP_NAME $usage"
    exit 1
}

add() {
    #validating input
    directory="$1"
    if [ ! -d "$directory" ]; then
        error_msg="missing directory"
        usage="add <directory>"
        error $error_msg $usage
    fi
    
    (
        IFS=$'\n'
        total_files_added=0
        for tune in `find $directory -type f -name *.m4a`
        do
            echo "--> Adding: ${tune#$directory}...\c"
            result=`osascript -e "tell application \"iTunes\" to add POSIX file \"$tune\""`
            if [ "$?" -eq 0 ]; then
                echo "OK"
                total_files_added=`expr $total_files_added + 1`
            fi
        done
        
        echo "Total files added: $total_files_added"
    )
}

# argument validation
if [ $# = 0 ]; then
    error_msg="missing option"
    usage="<option>"
    error $error_msg $usage
fi

# main
while [ $# -gt 0 ]; do
    opt=$1
    case $opt in
        "add"      ) add "$2";
        break ;;
        "help" | * ) help;
        break ;;
    esac 
done

