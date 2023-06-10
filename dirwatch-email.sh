#!/bin/bash

. /usr/libexec/dirwatch/dirwatch-lib.sh

path=$1

file=${path/*\//}
ext=${file/*./}

[ "X$ext" != "Xts" ] && exit 0

file_is_ready "$path" || exit 0

echo $file | mail -s "Uploaded to NEC Notification" production@talktalkplc.com

