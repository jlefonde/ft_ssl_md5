#!/usr/bin/env bats

setup() {
    load "../test_helper/bats-support/load"
    load "../test_helper/bats-assert/load"
}

setup_file() {
    echo "And above all," > file

    for file in "${files[@]}"; do
        if [ "$file" = "0B" ]; then
            > 0B
        elif [[ "${file: -2:1}" =~ ^[0-9]+$ ]] && [ "${file: -1}" = "B" ]; then
            dd if=/dev/urandom of="$file" bs="${file%?}" count=1 > /dev/null 2>&1
        else
            dd if=/dev/urandom of="$file" bs="$file" count=1 > /dev/null 2>&1
        fi
    done
}

teardown_file() {
    rm -f file

    for file in "${files[@]}"; do
        rm -f "$file"
    done
}
