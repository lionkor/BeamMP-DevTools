#!/bin/bash

server_list="$(curl --no-progress-meter -X GET https://backend.beammp.com/servers-info | jq '.')"

count_servers() {
    echo "$server_list" \
        | grep -i "ip" \
        | wc -l
}

get_all_players() {
    echo "$server_list" \
        | grep -i "\"playerslist\"" \
        | sed 's/\"playerslist\"\:\s//' \
        | sed 's/\"\"\,//' \
        | grep -v "^\s*$" \
        | sed 's/^\s*\"//' \
        | sed -r 's/\"\,//' \
        | tr -d \\n \
        | awk -F\; '{ for (i=0; i<NF; i++) printf "%s\n",$i;  }' \
        | sort
}

get_duplicate_names() {
    get_all_players \
        | uniq -D \
        | uniq \
        | sort
}

count_unique_players() {
    get_all_players $1 \
        | uniq \
        | wc -l
}

count_non_unique_players() {
    get_all_players $1 \
        | wc -l
}

get_all_duplicate_players() {
    get_all_players \
        | uniq -D
}

get_duplicates_minus_unique_count() {
    dc -e "$(get_all_duplicate_players | wc -l) $(get_all_duplicate_players | uniq | wc -l) - p"
}

count_ratio_fake_to_total() {
    dc -e "\
        1 \
        k \
        $(count_non_unique_players) \
        $(get_duplicates_minus_unique_count) \
        / \
        p"
}

echo "server count        : $(count_servers)"
echo "players             : $(count_non_unique_players)"
echo "unique players      : $(count_unique_players)"
echo "ghost players       : $(get_duplicates_minus_unique_count)"
echo "duplicates/total    : $(count_ratio_fake_to_total)%"
echo "duplicate names     : $(get_duplicate_names | sed -z 's/\n/,/g' )"
