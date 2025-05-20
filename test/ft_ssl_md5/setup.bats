#!/usr/bin/env bats

setup() {
    load "../test_helper/bats-support/load"
    load "../test_helper/bats-assert/load"
}

setup_file() {
    echo "And above all," > file
    echo "" > 0B

    for file in "${!files[@]}"; do
        dd if=/dev/urandom of="$file" bs="${files[$file]}" count=1 > /dev/null 2>&1
    done
}

teardown_file() {
    rm -f file
    rm -f 0B

    for file in "${!files[@]}"; do
        rm -f "$file"
    done
}
