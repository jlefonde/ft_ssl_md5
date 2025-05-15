#!/bin/bash

BGREEN='\033[1;32m'
RESET='\033[0m'

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
echo -e "${BGREEN}               \/__/  \/____/  \/___/    \/__/  \/____/  \/_/  ${RESET}\n"

./test/bats/bin/bats test/ft_ssl_md5.bats
