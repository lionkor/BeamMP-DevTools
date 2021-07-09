#!/bin/bash

server_list="$(curl --no-progress-meter -X GET https://backend.beammp.com/servers-info)"

echo $server_list \
    | jq '.[].version' \
    | sort \
    | uniq -c \
    | sed 's/\"/:/' \
    | sed 's/\"//' \
    | awk -F\: '{ for (i=0; i<NF; i+=2) print strftime("%Y-%m-%dT%H:%M:%S") "    " "v"$2 $1;  }'
