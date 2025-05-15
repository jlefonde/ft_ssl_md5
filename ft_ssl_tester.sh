#!/bin/bash

set -e

BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
RESET='\033[0m'

echo -e "${BGREEN}_________________________________________________________________${RESET}"
echo -e "${BGREEN}   ___   __                                 ___                ${RESET}"
echo -e "${BGREEN} / ___\ /\ \__                             /\_ \               ${RESET}"
echo -e "${BGREEN}/\ \__/ \ \  _\              ____     ____ \//\ \              ${RESET}"
echo -e "${BGREEN}\ \  __\ \ \ \/             /  __\   /  __\  \ \ \             ${RESET}"
echo -e "${BGREEN} \ \ \_/  \ \ \_           /\__   \ /\__   \  \_\ \_           ${RESET}"
echo -e "${BGREEN}  \ \_\    \ \__\          \/\____/ \/\____/  /\____\          ${RESET}"
echo -e "${BGREEN}   \/_/     \/__/  _______  \/___/   \/___/   \/____/          ${RESET}"
echo -e "${BGREEN}                  /\______\                                    ${RESET}"
echo -e "${BGREEN}                  \/______/                                    ${RESET}"
echo -e "${BGREEN}            __                        __                       ${RESET}"
echo -e "${BGREEN}           /\ \__                    /\ \__                    ${RESET}"
echo -e "${BGREEN}           \ \  _\      __      ____ \ \  _\      __    _ __   ${RESET}"
echo -e "${BGREEN}            \ \ \/    / __ \   /  __\ \ \ \/    / __ \ /\  __\ ${RESET}"
echo -e "${BGREEN}             \ \ \_  /\  __/  /\__   \ \ \ \_  /\  __/ \ \ \/  ${RESET}"
echo -e "${BGREEN}              \ \__\ \ \____\ \/\____/  \ \__\ \ \____\ \ \_\  ${RESET}"
echo -e "${BGREEN}               \/__/  \/____/  \/___/    \/__/  \/____/  \/_/  ${RESET}"
echo -e "${BGREEN}_________________________________________________________________${RESET}\n"

options=("--filter-tags")

helper() {
    echo -e "usage: ./ft_ssl_tester.sh <project> [options]\n"
    echo -e "project:"
    for file in test/*.bats; do
        echo -e " $(basename "$file" .bats)"
    done
    echo -e "\noptions:"
    echo -e " --filter-tags <comma-separated-tag-list>"
}

helper_filter_tags() {
    echo -e "usage: $1 --filter-tags <comma-separated-tag-list>\n"
    echo -e "tags:"
    grep -E '^# bats file_tags=' test/*.bats | sed -E 's/^# bats file_tags=//' | tr ',' '\n' | sort -u | sed 's/^/ /'
}

if [ -z $1 ]; then
    helper
    exit 1
fi

project_test_file="test/$1.bats"

if [ ! -f $project_test_file ]; then
    echo -e "${BRED}ERROR: Project \"$1\" test file not found${RESET}"
    exit 1
fi

if [ ! -z $2 ]; then
    is_valid_option=false
    for option in "${options[@]}"; do
        if [ "$2" == "$option" ]; then
            is_valid_option=true
            break
        fi
    done

    if [ "$is_valid_option" = false ]; then
        echo -e "${BRED}ERROR: Unknown option \"$2\"${RESET}"
        helper
        exit 1
    fi
fi

if [ "$2" = "--filter-tags" ]  && [ -z $3 ]; then
    helper_filter_tags $1
    exit 1
fi

if [ "$2" = "--filter-tags" ] && [ ! -z $3 ]; then
    echo -e "${BBLUE}Running tests with tag(s): $3${RESET}"
    ./test/bats/bin/bats $project_test_file --filter-tags $3
else
    ./test/bats/bin/bats $project_test_file
fi
