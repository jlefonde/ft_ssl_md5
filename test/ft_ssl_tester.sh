#!/bin/bash

set -e

BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
RESET='\033[0m'

./ft_ssl_md5/ft_ssl_md5.sh

if [ ! -d "bats" ]; then
    git clone https://github.com/bats-core/bats-core.git bats
fi

if [ ! -d "test_helper/bats-support" ]; then
    git clone https://github.com/bats-core/bats-support.git test_helper/bats-support
fi

if [ ! -d "test_helper/bats-assert" ]; then
    git clone https://github.com/bats-core/bats-assert.git test_helper/bats-assert
fi

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

project_test_file="$1/$1.bats"
projects=("ft_ssl_md5" "ft_ssl_des" "ft_ssl_rsa")
options=("-t")

helper() {
    echo -e "usage: ./ft_ssl_tester.sh <project> [options]\n"
    echo -e "project:"
    for project in ${projects[@]}; do
        echo -e " $project"
    done
    echo -e "\noptions:"
    echo -e " -t <comma-separated-tag-list>"
}

helper_filter_tags() {
    echo -e "usage: $1 -t <comma-separated-tag-list>\n"
    echo -e "tags:"
    grep -E '^# bats file_tags=' $project_test_file | sed -E 's/^# bats file_tags=//' | tr ',' '\n' | sort -u | sed 's/^/ /'
}

if [ -z $1 ]; then
    helper
    exit 1
fi

is_valid_project=false
for project in "${projects[@]}"; do
    if [ "$1" == "$project" ]; then
        is_valid_project=true
        break
    fi
done

if [ "$is_valid_project" = false ]; then
    echo -e "${BRED}ERROR: Unknown project \"$1\"${RESET}"
    helper
    exit 1
fi

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

if [ "$2" = "-t" ] && [ -z "$3" ]; then
    helper_filter_tags $1
    exit 1
fi

if [ "$2" = "-t" ]; then
    echo -e "${BBLUE}Running tests with tag(s): $3${RESET}"
    ./bats/bin/bats $project_test_file --filter-tags "$3"
else
    ./bats/bin/bats $project_test_file
fi
