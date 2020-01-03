#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

home="/home/f5/scripts"
dcdip="10.1.10.6"

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
if [  $already -gt 2 ]; then
    echo "The script is already running `expr $already - 2` time."
    killall $(basename "$0") > /dev/null 2>&1
    exit 1
fi

cd $home/DoSPlayback
$home/eventSender.py -l $dcdip

cd $home/AFMPlayback
$home/eventSender.py -l $dcdip