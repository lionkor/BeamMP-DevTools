#!/bin/bash

server_list="$(curl --no-progress-meter -X GET https://backend.beammp.com/servers-info)"

date "+%T;"

echo $server_list \
    | jq '.[].version' \
    | sort \
    | uniq -c \
    | sed 's/\"/:/' \
    | sed 's/\"//' \
    | awk -F\: '{ for (i=0; i<NF; i+=2) print $2 $1;  }'

echo ";"

