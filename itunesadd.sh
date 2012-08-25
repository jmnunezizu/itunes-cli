#!/bin/sh
APP_NAME=`basename $0`

# validate arguments
if [ $# -ne 1 ]
then
    echo "Error: missing directory"
    echo "Usage: $APP_NAME <directory>"
    exit 1
fi

DIRECTORY="$1"
ABSOLUTE_DIR=$(readlink -f "$DIRECTORY")

(
    IFS=$'\n'
    for tune in `find $DIRECTORY -type f -name *.m4a`
    do
        echo "--> Adding: $tune"
        osascript -e "tell application \"iTunes\" to add POSIX file \"$tune\""
    done
)
