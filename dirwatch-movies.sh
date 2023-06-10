#!/bin/bash

. /usr/libexec/dirwatch/dirwatch-lib.sh

atemedir=/fs/video/ateme/input
archive=/fs/video/original/mezzanine

filedir=$1 filename=$2 provider=$3
filepath="$filedir/$filename"

### do some stuff with a $filename

